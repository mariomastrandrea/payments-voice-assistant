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
    private var intentAndEntitiesExtractor: some IntentAndEntitiesExtractor {
        return BertIntentAndEntitiesExtractor()
    }
    
    func recognizeIntentAndExtractEntities(from userSpeech: String) {
        /* TODO: implement method (perform matching between the found entities and all the possible ones, like possible banks and user contacts) */
    }
    
}
    
