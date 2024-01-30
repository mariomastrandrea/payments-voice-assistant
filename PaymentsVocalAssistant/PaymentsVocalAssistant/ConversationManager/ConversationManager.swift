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
    
    init(speechRecognizer: SpeechRecognizer, dst: VocalAssistantDST, speechSyntesizer: SpeechSynthesizer, defaultErrorMessage: String) {
        self.speechRecognizer = speechRecognizer
        self.dst = dst
        self.speechSyntesizer = speechSyntesizer
        self.defaultErrorMessage = defaultErrorMessage
    }
    
    func startListening() {
        // start the speech recognizer
        self.speechRecognizer.startTranscribing()
    }
    
    func processAndPlayResponse() -> String {
        // TODO: stop recording, process the speech, convert to text, feed the DST, get the answer, play the answer, return the answer
        self.speechRecognizer.stopTranscribing()
        
        
        let answer = self.retrieveAnswer()
        self.speechSyntesizer.speak(text: answer)
        
        return answer
    }
    
    private func retrieveAnswer() -> String {
        let errorOccurred = self.speechRecognizer.errorOccurred
        let userTranscript = self.speechRecognizer.bestTranscript
        
        if errorOccurred {
            return defaultErrorMessage
        }
        
        let answer = self.dst.request(userTranscript)
        
        switch answer {
            case .followUpQuestion(let question): 
                return question
            default: 
                return "sadfghdsfghfrgjreth"
        }
    }
}
