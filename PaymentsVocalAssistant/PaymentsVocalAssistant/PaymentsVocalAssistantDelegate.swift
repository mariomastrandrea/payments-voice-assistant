//
//  PaymentsVocalAssistantDelegate.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 02/02/24.
//

import Foundation

/** Interface of the App Delegate in charge of actually performing the operations requested by the user to the `PaymentsVocalAssistant` */
public protocol PaymentsVocalAssistantDelegate {
    
    /** 
    Check the user's balance for a specific bank account
    - parameter bankAccount: the specific bank account whose balance has to be checked
    - returns: the requested amount
    */
    func performInAppCheckBalanceOperation(for bankAccount: VocalAssistantBankAccount) async throws -> VocalAssistantAmount
    
    /**
     Check the user's last transactions involving a specific bank account
     - parameter bankAccount: the specific bank account whose last transactions have to be checked
     - returns: the list of the requested transactions
     */
    func performInAppCheckLastTransactionsOperation(for bankAccount: VocalAssistantBankAccount) async throws -> [VocalAssistantTransaction]
    
    /**
     Check the user's last transactions involving a specific contact, either as receiver or as sender
     - parameter bankAccount: the specific contact whose last transactions have to be checked
     - returns: the list of the requested transactions
     */
    func performInAppCheckLastTransactionsOperation(involving contact: VocalAssistantContact) async throws -> [VocalAssistantTransaction]
    
    /**
     Check the user's last transactions
     - returns: the list of the requested transactions
     */
    func performInAppCheckLastTransactionsOperation() async throws -> [VocalAssistantTransaction]
    
    /**
     Send an amount of money to a specific contact, using a specified user's bank account
     - parameter amount: the amount which has to be sent in the transaction
     - parameter receiver: the contact who will receive the money
     - parameter bankAccount: the user's bank account where the money has to be taken from
     - returns: a boolean indicating if the transaction was successful or not, and an associated error message, if any
     */
    func performInAppSendMoneyOperation(amount: VocalAssistantAmount, to receiver: VocalAssistantContact, using bankAccount: VocalAssistantBankAccount) async throws -> (success: Bool, errorMsg: String?)
    
    /**
     Request an amount of money to a specific contact, using a specified user's bank account
     - parameter amount: the amount of money requested
     - parameter sender: the contact who will be requested the money from
     - parameter bankAccount: the user's bank account where the money will be delivered, if the transaction will be successful
     - returns: a boolean indicating if the request has been successfully sent or not, and an associated error message, if any
     */
    func performInAppRequestMoneyOperation(amount: VocalAssistantAmount, from sender: VocalAssistantContact, using bankAccount: VocalAssistantBankAccount) async throws -> (success: Bool, errorMsg: String?)
}

class AppDelegateStub: PaymentsVocalAssistantDelegate {
    private static let dollarCurrency = VocalAssistantCurrency(id: "$", symbols: ["$", "USD"], literals: ["dollar"])
    private static let aedCurrency = VocalAssistantCurrency(id: "AED", symbols: ["AED"], literals: ["dirham"])
    
    private static let topBankAccount = VocalAssistantBankAccount(id: "1", name: "Top Bank", default: true, currency: dollarCurrency)
    private static let futureBankAccount = VocalAssistantBankAccount(id: "2", name: "Future Bank", default: false, currency: aedCurrency)
    
    private static let antonioRossiContact = VocalAssistantContact(id: "01234567", firstName: "Antonio", lastName: "Rossi")
    private static let giuseppeVerdiContact = VocalAssistantContact(id: "12333444", firstName: "Giuseppe", lastName: "Verdi")
    
    private static let lastTransactions: [VocalAssistantTransaction] = [
        VocalAssistantTransaction(
            amount: VocalAssistantAmount(
                value: 20.5,
                currency: AppDelegateStub.dollarCurrency
            ),
            contact: AppDelegateStub.antonioRossiContact,
            bankAccount: AppDelegateStub.topBankAccount,
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        ),
        VocalAssistantTransaction(
            amount: VocalAssistantAmount(
                value: -17.0,
                currency: AppDelegateStub.aedCurrency
            ),
            contact: AppDelegateStub.giuseppeVerdiContact,
            bankAccount: AppDelegateStub.futureBankAccount,
            date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        ),
        VocalAssistantTransaction(
            amount: VocalAssistantAmount(
                value: 2.50,
                currency: AppDelegateStub.dollarCurrency
            ),
            contact: AppDelegateStub.giuseppeVerdiContact,
            bankAccount: AppDelegateStub.topBankAccount,
            date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        ),
        VocalAssistantTransaction(
            amount: VocalAssistantAmount(
                value: 49.89,
                currency: AppDelegateStub.dollarCurrency
            ),
            contact: AppDelegateStub.antonioRossiContact,
            bankAccount: AppDelegateStub.topBankAccount,
            date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!
        ),
        VocalAssistantTransaction(
            amount: VocalAssistantAmount(
                value: -20.50,
                currency: AppDelegateStub.dollarCurrency
            ),
            contact: AppDelegateStub.giuseppeVerdiContact,
            bankAccount: AppDelegateStub.topBankAccount,
            date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        ),
        VocalAssistantTransaction(
            amount: VocalAssistantAmount(
                value: -7.80,
                currency: AppDelegateStub.aedCurrency
            ),
            contact: AppDelegateStub.antonioRossiContact,
            bankAccount: AppDelegateStub.futureBankAccount,
            date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        )
    ]
    
    
    func 
    performInAppCheckBalanceOperation(for bankAccount: VocalAssistantBankAccount) async throws -> VocalAssistantAmount {
        let fakeAmount = VocalAssistantAmount(
            value: 127.88,
            currency: AppDelegateStub.dollarCurrency
        )
        logInfo("App delegate stub performed check balance: \(fakeAmount.description)")
        return fakeAmount
    }
    
    func performInAppCheckLastTransactionsOperation(for bankAccount: VocalAssistantBankAccount) async throws -> [VocalAssistantTransaction] {
        
        let fakeTransactions = AppDelegateStub.lastTransactions.filter { transaction in
            transaction.bankAccount.id == bankAccount.id
        }
        return fakeTransactions
    }
    
    func performInAppCheckLastTransactionsOperation(involving contact: VocalAssistantContact) async throws -> [VocalAssistantTransaction] {
        
        let fakeTransactions = AppDelegateStub.lastTransactions.filter { transaction in
            transaction.contact.id == contact.id
        }
        return fakeTransactions
    }
    
    func performInAppCheckLastTransactionsOperation() async throws -> [VocalAssistantTransaction] {
        return AppDelegateStub.lastTransactions
    }
    
    func performInAppSendMoneyOperation(amount: VocalAssistantAmount, to receiver: VocalAssistantContact, using bankAccount: VocalAssistantBankAccount) async throws -> (success: Bool, errorMsg: String?) {
        let outcome = [true, false].randomElement()!
        return (success: outcome, errorMsg: outcome ? nil : "You have unsufficient funds in the specified bank account")
    }
    
    func performInAppRequestMoneyOperation(amount: VocalAssistantAmount, from sender: VocalAssistantContact, using bankAccount: VocalAssistantBankAccount) async throws -> (success: Bool, errorMsg: String?) {
        let outcome = [true, false].randomElement()!
        return (success: outcome, errorMsg: outcome ? nil : "An unexpected error occurred processing the request money operation")
    }
}
