//
//  ConversationManager.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 30/01/24.
//

import Foundation

/** Object to fully interact with the `PaymentsVocalAssissant` and carry out a conversation.
    It represent the higher interface to interact with the Vocal Assistant, recording and provide it a speech, and playing the response */
public class ConversationManager {
    private let speechRecognizer: SpeechRecognizer
    internal let dst: VocalAssistantDst
    private let speechSyntesizer: SpeechSynthesizer
    private let appDelegate: PaymentsVocalAssistantDelegate
    private let defaultErrorMessage: String
    
    
    init(speechRecognizer: SpeechRecognizer, dst: VocalAssistantDst, speechSyntesizer: SpeechSynthesizer, appDelegate: PaymentsVocalAssistantDelegate, defaultErrorMessage: String) {
        self.speechRecognizer = speechRecognizer
        self.dst = dst
        self.speechSyntesizer = speechSyntesizer
        self.appDelegate = appDelegate
        self.defaultErrorMessage = defaultErrorMessage
        
    }
    
    func startConversation() -> String {
        let startConversationMessage = self.dst.startConversation()
        self.speechSyntesizer.speak(text: startConversationMessage)
        return startConversationMessage
    }
    
    func startListening() {
        // stop any previous speech of the SpeechSynthesizer
        self.speechSyntesizer.stopSpeaking()
        
        // start the speech recognizer
        self.speechRecognizer.startTranscribing()
        logInfo("Start recording...")
    }
    
    func processAndPlayResponse() async -> VocalAssistantResponse {
        // stop the recording and process the speech, converting it into a transcript
        logInfo("Stop recording")
        self.speechRecognizer.stopTranscribing()
        
        // feed and retrieve response from the DST, and eventually perform any operation requested by the user
        let response = await self.retrieveResponseAndEventuallyPerformInAppOperation()
        
        // play the response out loud and return it
        self.speechSyntesizer.speak(text: response.completeAnswer)
        logInfo(response.completeAnswer)
        
        return response
    }
    
    private func retrieveResponseAndEventuallyPerformInAppOperation() async -> VocalAssistantResponse {
        let errorOccurred = self.speechRecognizer.errorOccurred
        let transcript = self.speechRecognizer.bestTranscript
        
        if errorOccurred {
            return .appError(
                errorMessage: transcript,
                answer: defaultErrorMessage,
                followUpQuestion: "How can I help you?"
            )
        }
        
        logInfo("User transcript: \"\(transcript)\"")
        let dstResponse = self.dst.request(transcript)
        
        if case .performInAppOperation(let userIntent, let successMessage, let failureMessage, _, let followUpQuestion) = dstResponse {
            // perform in app operation, construct the answer and return a new response
            
            let answer: String
            
            switch userIntent {
            case .checkBalance(let bankAccount):
                do {
                    let balanceAmount = try await self.appDelegate.performInAppCheckBalanceOperation(for: bankAccount)
                    logInfo("Successfully performed in-app check balance operation for \(bankAccount) account -> \(balanceAmount)")
                    answer = successMessage.replacingOccurrences(of: "{amount}", with: balanceAmount.description)
                }
                catch {
                    logError("An error occurred performing in-app check balance operation: \(error)")
                    answer = failureMessage
                }
                
            case .checkLastTransactions(let bankAccount, let contact):
                do {
                    let transactions = try await self.appDelegate.performInAppCheckLastTransactionsOperation(for: bankAccount, involving: contact)
                    if transactions.isEmpty {
                        answer = "You didn't perform any transaction in the last period\(bankAccount == nil ? "" : " with your \(bankAccount!.name) account")\(contact == nil ? "" : " involving \(contact!.description)")."
                    }
                    else {
                        answer = successMessage.replacingOccurrences(
                            of: "{transactions}",
                            with: transactions.map { $0.description }.joined(separator: "\n")
                        )
                    }
                    logInfo("Successfully performed in-app check last transactions\(bankAccount == nil ? "" : " for \(bankAccount!.name) account")\(contact == nil ? "" : " involving \(contact!.description)") -> #\(transactions.count) transactions ")
                }
                catch {
                    logError("An error occurred performing in-app check transactions operation\(bankAccount == nil ? "" : " for \(bankAccount!.name) account")\(contact == nil ? "" : " involving \(contact!.description)"): \(error)")
                    answer = failureMessage
                }
                
            case .sendMoney(let amount, let recipient, let sourceAccount):
                do {
                    let (successfulOutcome, errorMsg) = try await self.appDelegate.performInAppSendMoneyOperation(amount: amount, to: recipient, using: sourceAccount)
                    
                    if successfulOutcome {
                        answer = successMessage
                        logInfo("Successfully performed in-app operation send money (with amount \(amount), to \(recipient) and using \(sourceAccount) account)")
                    }
                    else {
                        answer = failureMessage.replacingOccurrences(of: "{errorMsg}", with: errorMsg ?? "an unexpected error occurred")
                        logWarning("An error occurred performing in-app operation send money (with amount \(amount), to \(recipient) and using \(sourceAccount) account). Error msg: \(errorMsg ?? "none")")
                    }
                }
                catch {
                    logError("An error occurred performing in-app send money operation (with amount \(amount), to \(recipient) and using \(sourceAccount) account): \(error)")
                    answer = failureMessage
                }
                
            case .requestMoney(let amount, let sender, let destinationAccount):
                do {
                    let (successfulOutcome, errorMsg) = try await self.appDelegate.performInAppRequestMoneyOperation(amount: amount, from: sender, using: destinationAccount)
                    
                    if successfulOutcome {
                        answer = successMessage
                        logInfo("Successfully performed in-app operation request money (with amount \(amount), from \(sender) and using \(destinationAccount) account)")
                    }
                    else {
                        answer = failureMessage.replacingOccurrences(of: "{errorMsg}", with: errorMsg ?? "an unexpected error occurred")
                        logWarning("An error occurred performing in-app operation request money (with amount \(amount), from \(sender) and using \(destinationAccount) account). Error msg: \(errorMsg ?? "none")")
                    }
                }
                catch {
                    logError("An error occurred performing in-app request money operation (with amount \(amount), from \(sender) and using \(destinationAccount) account): \(error)")
                    answer = failureMessage
                }
            }
            
            // return a new performInAppOperation response replacing the answer with the new one
            return .performInAppOperation(userIntent: userIntent, successMessage: successMessage, failureMessage: failureMessage, answer: answer, followUpQuestion: followUpQuestion)
        }
        else {
            return dstResponse
        }
    }
}
