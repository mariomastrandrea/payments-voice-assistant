//
//  PaymentsEntity.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 22/01/24.
//

import Foundation

struct PaymentsEntity {
    let type: PaymentsEntityType
    let tokens: [String]
    let tokensLabels: [Int]
    let tokensLabelsProbabilities: [Float32]
    
    var startToken: String {
        return self.tokens[0]
    }
    
    var endToken: String {
        return self.tokens[self.tokens.count-1]
    }
    
    /**
     List of tokens after reconstruction: all the tokens starting with '##' are put together to the previous one
     */
    var reconstructedTokens: [String] {
        var result = [String]()
        var lastToken = ""
        
        for (i, token) in self.tokens.enumerated() {
            if i > 0 && token.starts(with: "##") {
                lastToken += token
            }
            else {
                if lastToken.isNotEmpty {
                    result.append(lastToken)
                }
                lastToken = token
            }
        }
        
        result.append(lastToken)
        return result
    }
    
    init(type: PaymentsEntityType, tokens: [String], tokensLabels: [Int], tokensLabelsProbabilities: [Float32]) {
        self.type = type
        self.tokens = tokens
        self.tokensLabels = tokensLabels
        self.tokensLabelsProbabilities = tokensLabelsProbabilities
    }
}

extension PaymentsEntity {
    static var bioLabels: [String] = {
        var result = PaymentsEntityType.allCases.flatMap { ["B-\($0.labelName)", "I-\($0.labelName)"] }
        result.insert("O", at: 0)
        return result
    }()
    
    static var numEntitiesLabels: Int {
        return PaymentsEntityType.allCases.count*2 + 1
    }
    
    static var defaultLabel = 0
    
    static func isBioBegin(label: Int) -> Bool {
        return label > 0 && label < Self.bioLabels.count &&
                Self.bioLabels[label].starts(with: "B-")
    }
    
    static func isBioInside(label: Int, withRespectTo entityType: PaymentsEntityType) -> Bool {
        let beginLabel = entityType.beginLabel
        
        return label > 0 && label < Self.bioLabels.count &&
                beginLabel > 0 && beginLabel < Self.bioLabels.count &&
                label == beginLabel + 1
    }
}

enum PaymentsEntityType: String, CaseIterable {
    case amount
    case bank
    case currency
    case user
    
    var labelName: String {
        return self.rawValue.uppercased()
    }
    
    var beginLabel: Int {
        return (Self.allCases.firstIndex(of: self)! * 2) + 1
    }
    
    static func of(_ label: Int) -> Self? {
        let num = (label-1) / 2
        
        if num < 0 || num >= Self.allCases.count {
            return nil
        }
        
        return Self.allCases[label]
    }
}
