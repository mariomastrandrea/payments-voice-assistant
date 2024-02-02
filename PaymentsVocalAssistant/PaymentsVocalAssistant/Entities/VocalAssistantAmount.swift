//
//  VocalAssistantAmount.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 24/01/24.
//

import Foundation

/** Object representing an amount for the `PaymentsVocalAssistant`, made of a currency and a value */
public struct VocalAssistantAmount: CustomStringConvertible {
    /** The numercal value of the amount */
    public let value: Double
    
    private var signedTextValue: String {
        return self.value > 0 ? "+\(self.value)" : "\(self.value)"
    }
    
    /** The currency of the amount */
    public let currency: VocalAssistantCurrency
    
    public var description: String {
        if self.currency.symbols.isNotEmpty {
            return "\(self.currency.symbols[0]) \(self.signedTextValue)"
        }
        else if self.currency.literals.isNotEmpty {
            return "\(self.signedTextValue) \(self.currency.literals[0])s"
        }
        else {
            return "\(self.signedTextValue)"
        }
    }
    
    public init(value: Double, currency: VocalAssistantCurrency) {
        self.value = value
        self.currency = currency
    }
}
