//
//  config.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 16/01/24.
//

import Foundation

enum GlobalConfig {
    static let enableLogs = true
}

enum VocalAssistantConfig {
    // mapping num to intent label
    static let intentLabels = [
        "none",
        "check_balance",
        "check_transactions",
        "send_money",
        "request_money",
        "yes",
        "no"
    ]
    
    static var numIntentLabels: Int {
        return intentLabels.count
    }
    
    static var defaultIntentLabel = 0
    
    // mapping num to entity label
    static let entityLabels = [
        "O",
        "B-AMOUNT",
        "I-AMOUNT",
        "B-BANK",
        "I-BANK",
        "B-CURRENCY",
        "I-CURRENCY",
        "B-USER",
        "I-USER"
    ]
    
    static var numEntityLabels: Int {
        return entityLabels.count
    }
    
    static var defaultEntityLabel = 0
}
