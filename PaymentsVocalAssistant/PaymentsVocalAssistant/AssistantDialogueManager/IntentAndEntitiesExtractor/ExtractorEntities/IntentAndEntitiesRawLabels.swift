//
//  IntentAndEntitiesLabels.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 18/01/24.
//

import Foundation

/**
 An object enclosing the raw labels predicted by the model and the corresponding probabilities: the intent label (from the intent classification task) and
 the entities labels (from the Named Entity Recognition task)
 */
struct IntentAndEntitiesRawLabels {
    // intent recognition
    let intentLabel: Int
    let intentProbability: Float32
    
    // entity extraction
    let entitiesLabels: [Int]
    let entitiesProbabilities: [Float32]
}
