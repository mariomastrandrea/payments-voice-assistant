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
     Check the user's last transactions, eventually involving a specific bank account and/or a specific contact
     - parameter bankAccount: the specific bank account whose last transactions have to be checked
     - parameter contact: the specific contact whose last transactions have to be checked
     - returns: the list of the requested transactions
     */
    func performInAppCheckLastTransactionsOperation(for bankAccount: VocalAssistantBankAccount?, involving contact: VocalAssistantContact?) async throws -> [VocalAssistantTransaction]
    
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

public class AppDelegateStub: PaymentsVocalAssistantDelegate {
    public static let dollarCurrency = VocalAssistantCurrency(id: "$", symbols: ["$", "USD"], literals: ["dollar"])
    public static let aedCurrency = VocalAssistantCurrency(id: "AED", symbols: ["AED"], literals: ["dirham"])
    
    public static let topBankAccount = VocalAssistantBankAccount(id: "1", name: "Top Bank", default: true, currency: dollarCurrency)
    public static let futureBankAccount = VocalAssistantBankAccount(id: "2", name: "Future Bank", default: false, currency: aedCurrency)
    
    public static let antonioRossiContact = VocalAssistantContact(id: "01234567", firstName: "Antonio", lastName: "Rossi")
    public static let giuseppeVerdiContact = VocalAssistantContact(id: "12333444", firstName: "Giuseppe", lastName: "Verdi")
    
    public static let lastTransactionsStub: [VocalAssistantTransaction] = [
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
    
    private let contacts: [VocalAssistantContact]
    private let bankAccounts: [VocalAssistantBankAccount]
    private let lastTransactions: [VocalAssistantTransaction]

    
    public init(
        contacts: [VocalAssistantContact] = [
            AppDelegateStub.antonioRossiContact,
            AppDelegateStub.giuseppeVerdiContact
        ],
        bankAccounts: [VocalAssistantBankAccount] = [
            AppDelegateStub.futureBankAccount,
            AppDelegateStub.topBankAccount
        ],
        transactions: [VocalAssistantTransaction] = AppDelegateStub.lastTransactionsStub
    ) {
        self.contacts = contacts
        self.bankAccounts = bankAccounts
        self.lastTransactions = transactions
    }
    
    public func 
    performInAppCheckBalanceOperation(for bankAccount: VocalAssistantBankAccount) async throws -> VocalAssistantAmount {
        let amounts: [Double] = [127.88, 256.59, 44.80, 33.12, 40.11, 86.50, 167.22, 81.88]
        
        var bankAccountFakeBalances: [VocalAssistantBankAccount: VocalAssistantAmount] = [:]
        self.bankAccounts.forEach { bankAccount in
            let randomAmount = amounts.randomElement()!
            bankAccountFakeBalances[bankAccount] = VocalAssistantAmount(
                value: randomAmount,
                currency: bankAccount.currency
            )
        }
        
        let result = bankAccountFakeBalances.first { (b, _) in b.id == bankAccount.id }
        
        guard let (_, fakeAccountBalance) = result else {
            throw StubError(errorMsg: "\(bankAccount.name) bank account not found")
        }
        
        logInfo("App delegate stub performed check balance: \(fakeAccountBalance.description)")
        return fakeAccountBalance
    }
    
    public func performInAppCheckLastTransactionsOperation(for bankAccount: VocalAssistantBankAccount?, involving contact: VocalAssistantContact?) async throws -> [VocalAssistantTransaction] {
        
        let fakeTransactions = self.lastTransactions.filter { transaction in
            (bankAccount != nil ? transaction.bankAccount.id == bankAccount!.id : true) &&
            (contact != nil ? transaction.contact.id == contact!.id : true)
        }
        
        return fakeTransactions
    }
    
    public func performInAppSendMoneyOperation(amount: VocalAssistantAmount, to receiver: VocalAssistantContact, using bankAccount: VocalAssistantBankAccount) async throws -> (success: Bool, errorMsg: String?) {
        let outcome = [true, false].randomElement()!
        return (success: outcome, errorMsg: outcome ? nil : "You have unsufficient funds in the specified bank account")
    }
    
    public func performInAppRequestMoneyOperation(amount: VocalAssistantAmount, from sender: VocalAssistantContact, using bankAccount: VocalAssistantBankAccount) async throws -> (success: Bool, errorMsg: String?) {
        let outcome = [true, false].randomElement()!
        return (success: outcome, errorMsg: outcome ? nil : "An unexpected error occurred processing the request money operation")
    }
}

public struct StubError: Error, CustomStringConvertible {
    public let errorMsg: String
    
    public var description: String {
        return self.errorMsg
    }
    
    public init(errorMsg: String) {
        self.errorMsg = errorMsg
    }
}
