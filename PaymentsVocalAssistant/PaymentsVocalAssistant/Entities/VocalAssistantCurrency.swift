//
//  VocalAssistantCurrency.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 24/01/24.
//

import Foundation

/** Object representing a Currency for the `PaymentsVocalAssistant` */
public struct VocalAssistantCurrency {
    /** Unique id representing the currency */
    let id: String
    
    /** List of possible symbols representing the currency */
    let symbols: [String]
    
    /** List of possible names representing the same currency */
    let literals: [String]
}
