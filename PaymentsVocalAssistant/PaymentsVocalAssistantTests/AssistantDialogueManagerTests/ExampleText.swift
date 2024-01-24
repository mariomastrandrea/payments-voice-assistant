//
//  utlis.swift
//  PaymentsVocalAssistantTests
//
//  Created by Mario Mastrandrea on 24/01/24.
//

import Foundation
@testable import PaymentsVocalAssistant

struct ExtractorSample {
    let text: String
    let intent: PaymentsIntentType
    let entities: [PaymentsEntityType]
    
    init(_ text: String, _ intent: PaymentsIntentType, _ entities: [PaymentsEntityType]) {
        self.text = text
        self.intent = intent
        self.entities = entities
    }
}

enum ExampleText {
    // example of sentences
    static let _1 = ExtractorSample("I need the transaction history involving Ylenia Leone", .checkTransactions, [ .user])
    static let _2 = ExtractorSample("I am instructing a collection of $412.90 from sister-in-law Marta through my CaixaBank", .requestMoney, [.amount, .user, .bank])
    static let _3 = ExtractorSample("Please arrange a payment of AED419 and 14 cents to Rodolfo", .sendMoney, [.amount, .user])
    
    static let cic = ExtractorSample("I want to send 47 cents to Andrea Cic", .sendMoney, [.amount, .user])
    
    
    
}
