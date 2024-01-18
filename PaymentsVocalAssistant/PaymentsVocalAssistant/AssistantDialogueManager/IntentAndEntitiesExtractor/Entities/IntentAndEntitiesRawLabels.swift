//
//  IntentAndEntitiesLabels.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 18/01/24.
//

import Foundation

/**
 An object enclosing the raw labels predicted by the model: the intent label (from the intent classification task) and
 the entities labels (from the Named Entity Recognition task)
 */
struct IntentAndEntitiesRawLabels {
    let intentLabel: Int32
    let entitiesLabels: [Int32]
}
