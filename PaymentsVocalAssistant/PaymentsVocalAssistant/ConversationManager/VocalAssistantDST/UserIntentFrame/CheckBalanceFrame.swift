//
//  CheckBalanceFrame.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 28/01/24.
//

import Foundation

class CheckBalanceFrame: UserIntentFrame {
    var currency: VocalAssistantCurrency?
    var bankAccount: VocalAssistantBankAccount?
    
    
    init(currency: VocalAssistantCurrency? = nil, bankAccount: VocalAssistantBankAccount? = nil) {
        self.currency = currency
        self.bankAccount = bankAccount
    }
}
