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
public class VocalAssistantDST {
    // Machine Learning model extracting intent and entities from user transcripts
    internal let intentAndEntitiesExtractor: any IntentAndEntitiesExtractor
    
    // app context
    private let userContacts: [VocalAssistantContact]
    private let userBankAccounts: [VocalAssistantBankAccount]
    
    // conversation state
    private let currentUserIntentFrame: UserIntentFrame?
    
    internal init(
        intentAndEntitiesExtractor: any IntentAndEntitiesExtractor,
        userContacts: [VocalAssistantContact],
        userBankAccounts: [VocalAssistantBankAccount]
    ) {
        self.intentAndEntitiesExtractor = intentAndEntitiesExtractor
        self.userContacts = userContacts
        self.userBankAccounts = userBankAccounts
        self.currentUserIntentFrame = nil
    }
    
    // TODO: add proper return type
    // TODO: process user input transcript and generate output managing the conversation state
    internal func request(_ userTranscript: String) -> VocalAssistantResponse {
        let recognitionResult = self.intentAndEntitiesExtractor.recognize(from: userTranscript)
        
        guard recognitionResult.isSuccess else {
            let errorMessage = recognitionResult.failure!.message
            return .appError(errorMessage: errorMessage, followUpQuestion: DefaultVocalAssistantConfig.defaultErrorResponse)
        }
        
        let prediction = recognitionResult.success!
        
        // TODO: check intent probability, if below threshold ask to confirm the intent
        
        /* TODO: (later) perform matching between the found entities and all the possible ones, like possible banks and user contacts */
        
        // TODO: remove stub
        var stub = "the predicted intent is \(prediction.predictedIntent.type)"
        
        if prediction.predictedEntities.isNotEmpty {
            let entities = prediction.predictedEntities.map { $0.reconstructedEntity }
            stub.append(" with entities \(entities.joined(separator: ", "))")
        }
        
        return .followUpQuestion(question: stub)
    }
}
