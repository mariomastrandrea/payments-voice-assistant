//
//  PaymentsAssistantTextClassifier.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 17/01/24.
//

import Foundation

/**
 Object performing Intent classification and Dialogue State Tracking (DST) over the user speech's transcript
 */
public class AssistantDialogueManager {
    let intentAndEntitiesExtractor: any IntentAndEntitiesExtractor
    
    // TODO: define user contact and user bank account types
    private let userContacts: [Any]
    private let userBankAccounts: [Any]
    
    // TODO: add conversation state
    
    init(intentAndEntitiesExtractor: any IntentAndEntitiesExtractor, userContacts: [Any], userBankAccounts: [Any]) {
        self.intentAndEntitiesExtractor = intentAndEntitiesExtractor
        self.userContacts = userContacts
        self.userBankAccounts = userBankAccounts
    }
    
    // TODO: add proper return type
    private func recognizeIntentAndExtractEntities(from text: String) {
        let recognitionResult = self.intentAndEntitiesExtractor.recognize(from: text)
        
        guard recognitionResult.isSuccess else {
            // TODO: manage errors
            return
        }
        
        /* TODO: perform matching between the found entities and all the possible ones, like possible banks and user contacts */
    }
    
    // TODO: add proper return type
    // TODO: process user input transcript and generate output managing the conversation state
    func ask(_ userTranscript: String) {
        self.recognizeIntentAndExtractEntities(from: userTranscript)
    }
}
