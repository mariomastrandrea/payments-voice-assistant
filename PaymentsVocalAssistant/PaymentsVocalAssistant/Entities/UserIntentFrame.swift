//
//  UserIntentFrame.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 28/01/24.
//

import Foundation

/** Object representing a dialogue 'frame' together with its slots values: a kind of action the user is intended to perform in the application context */
public enum UserIntentFrame {
    case checkBalance(bankAccount: VocalAssistantBankAccount)
    
    case checkTransactions(successMessage: String, failureMessage: String)
    case checkBankAccountTransactions(bankAccount: VocalAssistantBankAccount)
    case checkTransactionsDealingWith(contact: VocalAssistantContact)
    
    case sendMoney(amount: VocalAssistantAmount, recipient: VocalAssistantContact, sourceAccount: VocalAssistantBankAccount)
    case requestMoney(amount: VocalAssistantAmount, sender: VocalAssistantContact, destinationAccount: VocalAssistantBankAccount)
}
