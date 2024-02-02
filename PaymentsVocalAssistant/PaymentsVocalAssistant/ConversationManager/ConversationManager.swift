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
    private let dst: VocalAssistantDst
    private let speechSyntesizer: SpeechSynthesizer
    private let defaultErrorMessage: String
    
    
    init(speechRecognizer: SpeechRecognizer, dst: VocalAssistantDst, speechSyntesizer: SpeechSynthesizer, defaultErrorMessage: String) {
        self.speechRecognizer = speechRecognizer
        self.dst = dst
        self.speechSyntesizer = speechSyntesizer
        self.defaultErrorMessage = defaultErrorMessage
        
        self.speechSyntesizer.speak(text: self.dst.startConversation())
    }
    
    func startListening() {
        // start the speech recognizer
        self.speechRecognizer.startTranscribing()
        logInfo("Start recording...")
    }
    
    func processAndPlayResponse() -> VocalAssistantResponse {
        // stop the recording and process the speech, converting it into a transcript
        logInfo("Stop recording")
        self.speechRecognizer.stopTranscribing()
        
        // feed and retrieve response from the DST
        let response = self.retrieveResponse()
        
        // play it out loud
        self.speechSyntesizer.speak(text: response.completeAnswer)
        logInfo(response.completeAnswer)
        
        return response
    }
    
    private func retrieveResponse() -> VocalAssistantResponse {
        let errorOccurred = self.speechRecognizer.errorOccurred
        let transcript = self.speechRecognizer.bestTranscript
        
        if errorOccurred {
            return .appError(
                errorMessage: transcript,
                answer: defaultErrorMessage,
                followUpQuestion: "How can I help you?"
            )
        }
        
        return self.dst.request(transcript)
    }
}
