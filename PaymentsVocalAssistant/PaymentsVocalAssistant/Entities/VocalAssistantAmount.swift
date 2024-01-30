//
//  VocalAssistantAmount.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 24/01/24.
//

import Foundation

/** Object representing an amount for the `PaymentsVocalAssistant`, made of a currency and a value */
public struct VocalAssistantAmount {
    /** The numercal value of the amount */
    public let value: Double
    
    /** The currency of the amount */
    public let currency: VocalAssistantCurrency
    
    public init(value: Double, currency: VocalAssistantCurrency) {
        self.value = value
        self.currency = currency
    }
}
