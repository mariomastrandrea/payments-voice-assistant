//
//  PaymentsIntent.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 21/01/24.
//

import Foundation

enum PaymentsIntent: String, CaseIterable {
    case none              = "none"                 // 0
    case checkBalance      = "check_balance"        // 1
    case checkTransactions = "check_transactions"   // 2
    case sendMoney         = "send_money"           // 3
    case requestMoney      = "request_money"        // 4
    case yes               = "yes"                  // 5
    case no                = "no"                   // 6
    
    var all: [Self] {
        return Self.allCases
    }
    
    var label: Int {
        return self.all.firstIndex(of: self)!
    }
    
    var labelName: String {
        return self.rawValue
    }
    
    static var numIntents: Int {
        return Self.allCases.count
    }
    
    static var defaultLabel = 0
}

