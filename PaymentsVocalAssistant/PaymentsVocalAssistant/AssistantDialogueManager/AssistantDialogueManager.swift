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
    private var intentAndEntitiesExtractor: (any IntentAndEntitiesExtractor)?
    
    init?() {
        guard let extractor = BertIntentAndEntitiesExtractor.instance else {
            // an error occurred in the initialization of the Intent and Entities extractor
            return nil
        }
        self.intentAndEntitiesExtractor = extractor
    }
    
    func recognizeIntentAndExtractEntities(from userSpeech: String) {
        /* TODO: implement method (perform matching between the found entities and all the possible ones, like possible banks and user contacts) */
    }
    
    // TODO: add method receiving user input transcript and managing the conversation state
    
}
    
