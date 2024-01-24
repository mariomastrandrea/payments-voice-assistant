//
//  UserBankAccount.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 24/01/24.
//

import Foundation

/** A generic interface for an object representing a Currency for the `PaymentsVocalAssistant` */
struct VocalAssistantCurrency {
    /** List of possible symbols representing the currency */
    var symbols: [String]
    
    /** List of possible names representing the same currency */
    var literals: [String]
}
