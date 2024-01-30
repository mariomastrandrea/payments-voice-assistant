//
//  SendMoneyFrame.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 28/01/24.
//

import Foundation

class SendMoneyFrame: UserIntentFrame {
    var amount: VocalAssistantAmount?
    var recipient: VocalAssistantContact?
    var sourceAccount: VocalAssistantBankAccount?

    
    init(amount: VocalAssistantAmount? = nil, recipient: VocalAssistantContact? = nil, sourceAccount: VocalAssistantBankAccount? = nil) {
        self.amount = amount
        self.recipient = recipient
        self.sourceAccount = sourceAccount
    }
}
