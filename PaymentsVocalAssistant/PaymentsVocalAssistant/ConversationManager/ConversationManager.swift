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
    private let speechRecognizer: Any?   // TODO: substitute type
    private let dst: VocalAssistantDST
    private let speechSyntesizer: Any?   // TODO: substitute type
    
    init(speechRecognizer: Any?, dst: VocalAssistantDST, speechSyntesizer: Any?) {
        self.speechRecognizer = speechRecognizer
        self.dst = dst
        self.speechSyntesizer = speechSyntesizer
    }
    
    func startListening() {
        // TODO: start the speech recognizer
    }
    
    func processAndPlayResponse() -> String {
        // TODO: stop recording, process the speech, convert to text, feed the DST, get the answer, play the answer, return the answer
        
        return "* TODO *"
    }
}
