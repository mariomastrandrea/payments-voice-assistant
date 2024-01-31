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
    private let dst: VocalAssistantDST
    private let speechSyntesizer: SpeechSynthesizer
    private let defaultErrorMessage: String
    private let startConversationMessage: String
    
    init(speechRecognizer: SpeechRecognizer, dst: VocalAssistantDST, speechSyntesizer: SpeechSynthesizer, defaultErrorMessage: String, startConversationMessage: String) {
        self.speechRecognizer = speechRecognizer
        self.dst = dst
        self.speechSyntesizer = speechSyntesizer
        self.defaultErrorMessage = defaultErrorMessage
        self.startConversationMessage = startConversationMessage
        
        self.speechSyntesizer.speak(text: startConversationMessage)
    }
    
    func startListening() {
        // start the speech recognizer
        self.speechRecognizer.startTranscribing()
        logInfo("Start recording...")
    }
    
    func processAndPlayResponse() -> VocalAssistantResponse {
        // TODO: stop recording, process the speech, convert to text, feed the DST, get the answer, play the answer, return the answer
        logInfo("Stop recording")
        self.speechRecognizer.stopTranscribing()
        
        
        let response = self.retrieveResponse()
        self.speechSyntesizer.speak(text: response.textAnswer)
        
        logInfo(response.textAnswer)
        
        return response
    }
    
    private func retrieveResponse() -> VocalAssistantResponse {
        let errorOccurred = self.speechRecognizer.errorOccurred
        let transcript = self.speechRecognizer.bestTranscript
        
        if errorOccurred {
            return .appError(
                errorMessage: transcript,
                followUpQuestion: defaultErrorMessage
            )
        }
        
        return self.dst.request(transcript)
    }
}
