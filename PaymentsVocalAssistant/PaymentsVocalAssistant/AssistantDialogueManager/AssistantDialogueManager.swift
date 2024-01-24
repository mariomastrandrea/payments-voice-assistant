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
    // Machine Learning model extracting intent and entities from user transcripts
    private let intentAndEntitiesExtractor: any IntentAndEntitiesExtractor
    
    // app context
    private let userContacts: [VocalAssistantUser]
    private let userBankAccounts: [VocalAssistantBankAccount]
    
    // TODO: add conversation state
    
    internal init(
        intentAndEntitiesExtractor: any IntentAndEntitiesExtractor,
        userContacts: [VocalAssistantUser], 
        userBankAccounts: [VocalAssistantBankAccount]
    ) {
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
