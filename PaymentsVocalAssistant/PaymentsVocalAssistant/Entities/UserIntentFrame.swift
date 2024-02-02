//
//  UserIntentFrame.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 28/01/24.
//

import Foundation

/** Object representing a dialogue 'frame' together with its slots values: a kind of action the user is intended to perform in the application context */
public enum UserIntentFrame {
    case checkBalance(bankAccount: VocalAssistantBankAccount, successMessage: String, failureMessage: String)
    case checkBankAccountTransactions(bankAccount: VocalAssistantBankAccount, successMessage: String, failureMessage: String)
    case checkTransactionsDealingWithUser(user: VocalAssistantContact, successMessage: String, failureMessage: String)
    case sendMoney(amount: VocalAssistantAmount, recipient: VocalAssistantContact, sourceAccount: VocalAssistantBankAccount, successMessage: String, failureMessage: String)
    case requestMoney(amount: VocalAssistantAmount, sender: VocalAssistantContact, destinationAccount: VocalAssistantBankAccount, successMessage: String, failureMessage: String)
}
