//
//  VocalAssistantBankAccount.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 24/01/24.
//

import Foundation

/** Object representing a unique bank account of the user for the `PaymentsVocalAssistant`
 
    It is characterized by a `name` property which will be used by the vocal assistant to identify the requested user in the speeches */
public struct VocalAssistantBankAccount {
    /** Unique id of the bank account in the app context */
    let id: String
    
    /** Name of the bank which will be matched by the vocal assistant */
    let name: String
    
    /** Flag indicating if this is the default (primary) account for the user */
    let `default`: Bool
    
    /** The specific currency for the bank account */
    let currency: VocalAssistantCurrency
}
