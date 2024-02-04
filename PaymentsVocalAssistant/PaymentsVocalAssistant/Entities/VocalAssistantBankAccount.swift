//
//  VocalAssistantBankAccount.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 24/01/24.
//

import Foundation

/** Object representing a unique bank account of the user for the `PaymentsVocalAssistant`
 
    It is characterized by a `name` property which will be used by the vocal assistant to identify the requested user in the speeches */
public struct VocalAssistantBankAccount: CustomStringConvertible, Hashable {
    /** Unique id of the bank account in the app context */
    public let id: String
    
    /** Name of the bank which will be matched by the vocal assistant */
    public let name: String
    
    /** Flag indicating if this is the default (primary) account for the user */
    public let `default`: Bool
    
    /** The specific currency for the bank account */
    public let currency: VocalAssistantCurrency
    
    public var description: String {
        return "\(self.name) (\(self.currency)\(self.default ? ", primary" : ""))"
    }
    
    
    public init(id: String, name: String, default: Bool, currency: VocalAssistantCurrency) {
        self.id = id
        self.name = name
        self.default = `default`
        self.currency = currency
    }
    
    func match(with literal: String) -> Bool {
        if literal == "default" || literal == "primary" {
            return self.default
        }
        
        return self.name.lowercased().similarity(with: literal.lowercased()) >= DefaultVocalAssistantConfig.similarityThreshold
    }
    
    public static func == (lhs: VocalAssistantBankAccount, rhs: VocalAssistantBankAccount) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    internal func toEntity() -> PaymentsEntity {
        return PaymentsEntity(
            type: .bank,
            reconstructedEntity: self.name,
            entityProbability: Float32(1.0),
            reconstructedTokens: self.name.splitByWhitespace(),
            rawTokens: [],
            tokensLabels: [],
            tokensLabelsProbabilities: []
        )
    }
}

extension Array where Element == VocalAssistantBankAccount {
    func joined() -> String {
        return self.map { $0.name }.joinGrammatically()
    }
}

