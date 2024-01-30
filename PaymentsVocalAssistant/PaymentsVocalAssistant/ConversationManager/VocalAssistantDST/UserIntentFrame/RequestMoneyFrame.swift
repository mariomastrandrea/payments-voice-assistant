//
//  RequestMoneyFrame.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 28/01/24.
//

import Foundation

class RequestMoneyFrame: UserIntentFrame {
    var amount: VocalAssistantAmount?
    var sender: VocalAssistantContact?
    var destinationAccount: VocalAssistantBankAccount?
    
    
    init(amount: VocalAssistantAmount? = nil, sender: VocalAssistantContact? = nil, destinationAccount: VocalAssistantBankAccount? = nil) {
        self.amount = amount
        self.sender = sender
        self.destinationAccount = destinationAccount
    }
}
