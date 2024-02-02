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
    
    public var sign: String {
        return self.value < 0 ? "-" : "+"
    }
    
    /** The currency of the amount */
    public let currency: VocalAssistantCurrency
    
    public var description: String {
        if self.currency.symbols.isNotEmpty {
            return "\(self.sign)\(self.currency.symbols[0])\(abs(self.value))"
        }
        else if self.currency.literals.isNotEmpty {
            return "\(self.sign)\(abs(self.value)) \(self.currency.literals[0])\(self.value == 1.0 ? "" : "s")"
        }
        else {
            return "\(self.sign)\(abs(self.value))"
        }
    }
    
    public init(value: Double, currency: VocalAssistantCurrency) {
        self.value = value
        self.currency = currency
    }
}
