//
//  PaymentsEntity.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 22/01/24.
//

import Foundation

struct PaymentsEntity: CustomStringConvertible {
    let type: PaymentsEntityType
    let rawTokens: [String]
    let tokensLabels: [Int]
    let tokensLabelsProbabilities: [Float32]
    let entityProbability: Float32
    
    var description: String {
        return """
        {
            entity_type: \(self.type),
            reconstructed_tokens: \(self.bertReconstructedTokens),
            raw_tokens: \(self.rawTokens),
            tokensLabels: \(self.tokensLabels.map{ Self.bioLabels[$0] }),
            tokensLabelsProbabilities: \(self.tokensLabelsProbabilities),
            entityProbability: \(self.entityProbability)
        }
        """
    }
    
    /**
     List of tokens after reconstruction: all the tokens starting with '##' are put together to the previous one
     */
    var bertReconstructedTokens: [String] {
        var result = [String]()
        var lastToken = ""
        
        for (i, token) in self.rawTokens.enumerated() {
            if i > 0 && token.starts(with: BertConfig.subtokenIdentifier) {
                
                lastToken += token.removeLeading(BertConfig.subtokenIdentifier)
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
    
    static func isValid(label: Int) -> Bool {
        return label >= 0 && label < Self.numEntitiesLabels
    }
}

enum PaymentsEntityType: String, CaseIterable, CustomStringConvertible {
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
    
    var description: String {
        return self.labelName
    }
    
    static func of(_ label: Int) -> Self? {
        let num = (label-1) / 2
        
        if num < 0 || num >= Self.allCases.count {
            return nil
        }
        
        return Self.allCases[num]
    }
}
