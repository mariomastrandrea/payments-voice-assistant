//
//  IntentAndEntitiesLabels.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 17/01/24.
//

import Foundation

/**
 An object enclosing a prediction of the IntentRecognizer: the intent (from the intent classification task) and
 the entities (from the Named Entity Recognition task)
 */
struct IntentAndEntitiesPrediction {
    // input
    let sentence: String
    let sentenceTokens: [String]
    
    // prediction
    let predictedIntent: PaymentsIntent
    let predictedEntities: [PaymentsEntity]
}

