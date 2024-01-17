//
//  IntentsAndEntitiesProbabilities.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 17/01/24.
//

import Foundation

/**
 An object enclosing the two output of the model: the intent recognition output probabilities, one for each intent, and
 the entity extraction output probabilities, one for each entity and for each token
 */
struct IntentsAndEntitiesProbabilities {
    let intentRecognitionOutput: [Float32]
    let entityExtractionOutput: [[Float32]]
}
