//
//  VocalAssistantTransaction.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 02/02/24.
//

import Foundation

/** Object representing a generic transaction (either positive or negative) for the `PaymentsVocalAssistant` */
public struct VocalAssistantTransaction: CustomStringConvertible {
    /** The amount of the transaction: it is be positive, if the transaction was incoming (money received), or negative, if the transaction was outgoing (payment)  */
    public let amount: VocalAssistantAmount
    
    /** The other account involved in the transaction, either as sender or receiver */
    public let contact: VocalAssistantContact
    
    /** The user's bank account involved in the transaction */
    public let bankAccount: VocalAssistantBankAccount
    
    /** The specific date when the transaction was processed */
    public let date: Date
    
    public var description: String {
        return "\(self.amount) \(self.amount.value < 0 ? "to" : "from") \(self.contact) - \(self.date) - \(self.bankAccount)"
    }
    
    
    public init(amount: VocalAssistantAmount, contact: VocalAssistantContact, bankAccount: VocalAssistantBankAccount, date: Date) {
        self.amount = amount
        self.contact = contact
        self.bankAccount = bankAccount
        self.date = date
    }
}
