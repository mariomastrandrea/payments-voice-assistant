//
//  PaymentsEntity.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 22/01/24.
//

import Foundation

struct PaymentsEntity: CustomStringConvertible {
    let type: PaymentsEntityType
    let reconstructedEntity: String
    let entityProbability: Float32
    private let reconstructedTokens: [String]
    private let rawTokens: [String]
    private let tokensLabels: [Int]
    private let tokensLabelsProbabilities: [Float32]

    var description: String {
        return """
        {
            entity_type: \"\(self.type)\",
            reconstructed_entity: \"\(self.reconstructedEntity)\",
            entity_probability: \(self.entityProbability),
            reconstructed_tokens: \(self.reconstructedTokens),
            raw_tokens: \(self.rawTokens),
            tokens_labels: \(self.tokensLabels.map{ Self.bioLabels[$0] }),
            tokens_labels_probabilities: \(self.tokensLabelsProbabilities),
        }
        """
    }
    
    init(type: PaymentsEntityType, reconstructedEntity: String, entityProbability: Float32,
         reconstructedTokens: [String], rawTokens: [String], tokensLabels: [Int], tokensLabelsProbabilities: [Float32]) {
        self.type = type
        self.reconstructedEntity = reconstructedEntity
        self.entityProbability = entityProbability
        self.reconstructedTokens = reconstructedTokens
        self.rawTokens = rawTokens
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
    
    static var defaultLabel: Int {
        return PaymentsEntityType.defaultLabel
    }
    
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
    
    static var defaultLabel = 0
    
    var beginLabel: Int {
        return (Self.allCases.firstIndex(of: self)! * 2) + 1
    }
    
    var insideLabel: Int {
        return self.beginLabel + 1
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
