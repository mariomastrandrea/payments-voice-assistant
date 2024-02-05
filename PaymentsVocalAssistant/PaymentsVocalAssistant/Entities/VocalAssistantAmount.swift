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
    
    public var roundedAbs: String {
        return String(format: "%.2f", abs(self.value))
    }
    
    /** The currency of the amount */
    public let currency: VocalAssistantCurrency
    
    public var description: String {
        if self.currency.symbols.isNotEmpty {
            return "\(self.sign)\(self.currency.symbols[0])\(self.roundedAbs)"
        }
        else if self.currency.literals.isNotEmpty {
            return "\(self.sign)\(self.roundedAbs) \(self.currency.literals[0])\(self.value == 1.0 ? "" : "s")"
        }
        else {
            return "\(self.sign)\(self.roundedAbs)"
        }
    }
    
    public var descriptionWithoutSign: String {
        return "\(self.currency.symbols[safe: 0] ?? self.currency.id)\(self.roundedAbs)"
    }
    
    public init(value: Double, currency: VocalAssistantCurrency) {
        self.value = value
        self.currency = currency
    }
    
    private static let literalDigits = ["one": 1, "two": 2, "three": 3, "four": 4, "five": 5, "six": 6, "seven": 7, "eight": 8, "nine": 9]
    private static var literalDigitsRegex: String {
        return literalDigits.keys.joined(separator: "|")
    }
    
    public init?(fromEntity literal: String, possibleCurrencies: [VocalAssistantCurrency]) {
        let literal = literal.lowercased()
        
        // first identify the currency
        guard let foundCurrency = possibleCurrencies.first(where: { possibleCurrency in
            possibleCurrency.symbols.contains { literal.contains($0.lowercased())} ||
            possibleCurrency.literals.contains { literal.contains($0.lowercased()) }
        }) else {
            return nil
        }
        
        self.currency = foundCurrency
        
        // now reconstruct the numerical amount
        
        // look for literal cents first
        let literalCentsRegex = "([\\d]+|\(VocalAssistantAmount.literalDigitsRegex)) cent(s)?"
        let literalCentsMatches = literal.findMatchesOf(regex: literalCentsRegex)
        
        if literalCentsMatches.isNotEmpty,
           let literalCents = literalCentsMatches[safe: 0]?.splitByWhitespace()[safe: 0],
           let cents = VocalAssistantAmount.literalDigits[literalCents] ?? Int(literalCents)
        {
            // found literal cents -> now look for the integer part
            
            // first with literal currency
            var possibleLiteralCurrenciesRegex = possibleCurrencies.flatMap { $0.literals.map{$0.lowercased()} }
                .map { "(\($0)(s)?)" }
                .joined(separator: "|")
            if possibleLiteralCurrenciesRegex.count > 1 {
                possibleLiteralCurrenciesRegex = "(" + possibleLiteralCurrenciesRegex + ")"
            }
            
            let literalCurrencyIntegerPartMatches = literal.findMatchesOf(
                regex: "([\\d]+|\(VocalAssistantAmount.literalDigitsRegex)) \(possibleLiteralCurrenciesRegex)"
            )
            
            if literalCurrencyIntegerPartMatches.isNotEmpty,
               let integerPartMatch = literalCurrencyIntegerPartMatches[safe: 0]?.splitByWhitespace()[safe: 0],
               let integerPart = VocalAssistantAmount.literalDigits[integerPartMatch] ?? Int(integerPartMatch)
            {
                // found also the integer part
                let amount = Double(integerPart) + (Double(cents) / 100.0)
                self.value = amount
                return
            }
            
            // or with symbolic currency
            var possibleSymbolicCurrenciesRegex = possibleCurrencies.flatMap { $0.symbols.map{$0.lowercased()} }
                                                                    .map { $0 == "$" ? "\\$" : $0 }
                                                                    .joined(separator: "|")
            
            if possibleSymbolicCurrenciesRegex.count > 1 {
                possibleSymbolicCurrenciesRegex = "(" + possibleSymbolicCurrenciesRegex + ")"
            }
            
            let symbolicCurrencyIntegerPartMatches = literal.findMatchesOf(
                regex: "\(possibleSymbolicCurrenciesRegex) ?([\\d]+|\(VocalAssistantAmount.literalDigitsRegex))"
            )
            
            if symbolicCurrencyIntegerPartMatches.isNotEmpty {
                var integerPartMatch = symbolicCurrencyIntegerPartMatches[0]
                
                for symbol in possibleCurrencies.flatMap({ $0.symbols.map{$0.lowercased()} }) {
                    integerPartMatch = integerPartMatch.replacingOccurrences(of: symbol, with: "")
                }
                
                integerPartMatch = integerPartMatch.trimmingCharacters(in: .whitespacesAndNewlines)
                
                // just the integer number is there now (either as literal or as digit(s))
                
                if let integerPart = VocalAssistantAmount.literalDigits[integerPartMatch] ?? Int(integerPartMatch) {
                    // found also the integer part
                    let amount = Double(integerPart) + (Double(cents) / 100.0)
                    self.value = amount
                    return
                }
            }
        }
        
        // look for amount with literal currency
        var possibleLiteralCurrenciesRegex = possibleCurrencies.flatMap { $0.literals.map{$0.lowercased()} }
            .map { "(\($0)(s)?)" }
            .joined(separator: "|")
        if possibleLiteralCurrenciesRegex.count > 1 {
            possibleLiteralCurrenciesRegex = "(" + possibleLiteralCurrenciesRegex + ")"
        }
        
        let literalCurrencyAmountMatches = literal.findMatchesOf(
            regex: "([\\d]+(.[\\d]{1,2})?|\(VocalAssistantAmount.literalDigitsRegex)) \(possibleLiteralCurrenciesRegex)"
        )
        
        if literalCurrencyAmountMatches.isNotEmpty,
           let literalCurrencyAmountMatch = literalCurrencyAmountMatches[safe: 0]?.splitByWhitespace()[safe: 0],
           let valueMatch = VocalAssistantAmount.literalDigits[literalCurrencyAmountMatch]?.toDouble() ?? Double(literalCurrencyAmountMatch) {
            self.value = valueMatch
            return
        }
        
        // look for amount with symbolic currency
        var possibleSymbolicCurrenciesRegex = possibleCurrencies.flatMap { $0.symbols.map{$0.lowercased()} }
                                                                .map { $0 == "$" ? "\\$" : $0  }
                                                                .joined(separator: "|")
        
        if possibleSymbolicCurrenciesRegex.count > 1 {
            possibleSymbolicCurrenciesRegex = "(" + possibleSymbolicCurrenciesRegex + ")"
        }
        
        let symbolicCurrencyAmountMatches = literal.findMatchesOf(
            regex: "\(possibleSymbolicCurrenciesRegex) ?([\\d]+(.[\\d]{1,2})?|\(VocalAssistantAmount.literalDigitsRegex))"
        )
        
        if symbolicCurrencyAmountMatches.isNotEmpty {
            var symbolicCurrencyAmountMatch = symbolicCurrencyAmountMatches[0]
            
            for symbol in possibleCurrencies.flatMap({ $0.symbols.map{$0.lowercased()} }) {
                symbolicCurrencyAmountMatch = symbolicCurrencyAmountMatch.replacingOccurrences(of: symbol, with: "")
            }
            
            symbolicCurrencyAmountMatch = symbolicCurrencyAmountMatch.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // now just the number is there
            if let value = VocalAssistantAmount.literalDigits[symbolicCurrencyAmountMatch]?.toDouble() ?? Double(symbolicCurrencyAmountMatch) {
                self.value = value
                return
            }
        }
        
        return nil
    }
    
    internal func toEntity() -> PaymentsEntity {
        return PaymentsEntity(
            type: .amount,
            reconstructedEntity: self.descriptionWithoutSign,
            entityProbability: Float32(1.0),
            reconstructedTokens: self.descriptionWithoutSign.splitByWhitespace(),
            rawTokens: [],
            tokensLabels: [],
            tokensLabelsProbabilities: []
        )
    }
}
