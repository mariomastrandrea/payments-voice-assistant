//
//  PaymentsIntent.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 22/01/24.
//

import Foundation

/**
 An object enclosing the type of intent expressed by the user and the corresponding probability
 */
struct PaymentsIntent: CustomStringConvertible {
    let type: PaymentsIntentType
    let probability: Float32
    
    var description: String {
        return """
        {
            intent_type: \(self.type),
            probability: \(self.probability)
        }
        """
    }
    
    init(type: PaymentsIntentType, probability: Float32) {
        self.type = type
        self.probability = probability
    }
    
    init?(label: Int, probability: Float32) {
        if label < 0 || label >= PaymentsIntentType.numIntents {
            return nil
        }
        
        let intentType = PaymentsIntentType.all[label]
        
        self.type = intentType
        self.probability = probability
    }
}

/**
 An enum indicating the type of intent expressed by the user
 */
enum PaymentsIntentType: String, CaseIterable, CustomStringConvertible {
    case none              = "none"                 // 0
    case checkBalance      = "check_balance"        // 1
    case checkTransactions = "check_transactions"   // 2
    case sendMoney         = "send_money"           // 3
    case requestMoney      = "request_money"        // 4
    case yes               = "yes"                  // 5
    case no                = "no"                   // 6
    
    var label: Int {
        return Self.all.firstIndex(of: self)!
    }
    
    var labelName: String {
        return self.rawValue
    }
    
    var description: String {
        return self.rawValue
    }
}

extension PaymentsIntentType {
    // static properties
    
    static var all: [Self] {
        return Self.allCases
    }
    
    static var numIntents: Int {
        return Self.allCases.count
    }
    
    static var defaultLabel = 0
}

