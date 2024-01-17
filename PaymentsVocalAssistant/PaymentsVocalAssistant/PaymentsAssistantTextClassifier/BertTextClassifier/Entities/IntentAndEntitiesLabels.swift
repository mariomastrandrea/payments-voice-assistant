//
//  IntentAndEntitiesLabels.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 17/01/24.
//

import Foundation

/**
 An object enclosing the labels predicted by the model: the intent label (from the intent classification task) and
 the entities labels (from the Named Entity Recognition task)
 */
struct IntentAndEntitiesLabels {
    let intentLabel: Any    // TODO: change to proper type
    let entitiesLabels: Any // TODO: change to proper type
}

