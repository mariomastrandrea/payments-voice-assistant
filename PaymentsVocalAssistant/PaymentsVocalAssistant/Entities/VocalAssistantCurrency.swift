//
//  VocalAssistantCurrency.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 24/01/24.
//

import Foundation

/** Object representing a Currency for the `PaymentsVocalAssistant` */
public struct VocalAssistantCurrency: CustomStringConvertible, Hashable {
    /** Unique id representing the currency */
    public let id: String
    
    /** List of possible symbols representing the currency */
    public let symbols: [String]
    
    /** List of possible names representing the same currency */
    public let literals: [String]
    
    public var description: String {
        return self.id
    }
    
    
    public init(id: String, symbols: [String], literals: [String]) {
        self.id = id
        self.symbols = symbols
        self.literals = literals
    }
    
    func match(with literal: String) -> Bool {
        return literals.contains { currencyLiteral in
            currencyLiteral.similarity(with: literal) > DefaultVocalAssistantConfig.similarityThreshold
        } || symbols.contains { currencySymbol in
            currencySymbol.similarity(with: literal) > DefaultVocalAssistantConfig.similarityThreshold
        }
    }
    
    public static func == (lhs: VocalAssistantCurrency, rhs: VocalAssistantCurrency) -> Bool {
        return lhs.id == rhs.id
    }
}
