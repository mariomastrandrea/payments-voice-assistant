//
//  IntentsAndEntitiesProbabilities.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 17/01/24.
//

import Foundation

/**
 An object enclosing the two outputs of the model: (1) the intent recognition output probabilities, one for each intent, and (2) the entity extraction output probabilities, one for each entity and for each token
 */
struct IntentsAndEntitiesProbabilities {
    let intentRecognitionOutput: [Float32]
    let entityExtractionOutput: [[Float32]]
}
