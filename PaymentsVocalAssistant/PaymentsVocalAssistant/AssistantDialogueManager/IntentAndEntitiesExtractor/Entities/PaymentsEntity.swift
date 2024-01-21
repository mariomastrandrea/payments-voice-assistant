//
//  PaymentsEntity.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 22/01/24.
//

import Foundation

enum PaymentsEntity: String, CaseIterable {
    case amount
    case bank
    case currency
    case user
    
    static var numEntitiesLabels: Int {
        return Self.allCases.count * 2 + 1
    }
    
    static var bioLabels: [String] {
        var result = Self.allCases.flatMap { ["B-\($0.rawValue)", "I-\($0.rawValue)"] }
        result.insert("O", at: 0)
        return result
    }
    
    static var defaultLabel = 0
    
    var labelName: String {
        switch self {
            case .amount:   return "AMOUNT"
            case .bank:     return "BANK"
            case .currency: return "CURRENCY"
            case .user:     return "USER"
        }
    }
    
    // TODO: finish declaration
}
