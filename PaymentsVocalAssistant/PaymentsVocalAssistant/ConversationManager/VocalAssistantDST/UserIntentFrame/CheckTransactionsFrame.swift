//
//  CheckTransactionsFrame.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 28/01/24.
//

import Foundation

class CheckTransactionsFrame: UserIntentFrame {
    var bankAccount: VocalAssistantBankAccount?
    var user: VocalAssistantContact?

    
    init(bankAccount: VocalAssistantBankAccount? = nil, user: VocalAssistantContact? = nil) {
        self.bankAccount = bankAccount
        self.user = user
    }
}
