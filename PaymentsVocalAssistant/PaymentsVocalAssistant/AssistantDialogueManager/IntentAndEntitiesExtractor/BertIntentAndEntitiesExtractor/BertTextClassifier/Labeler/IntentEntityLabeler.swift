//
//  EntityIntentLabeler.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 17/01/24.
//

import Foundation

class IntentEntityLabeler: ModelLabeler {
    typealias ModelOutput = IntentsAndEntitiesProbabilities
    typealias PredictedLabels = IntentAndEntitiesLabels
    
    func predictLabels(from probabilities: IntentsAndEntitiesProbabilities) -> IntentAndEntitiesLabels {
        // TODO: implement method (use thresholds and assign numeric labels) 
        exit(1)
    }
}
