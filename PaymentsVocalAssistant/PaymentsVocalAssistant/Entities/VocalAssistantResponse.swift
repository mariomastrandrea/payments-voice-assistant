//
//  AssistantResponse.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 28/01/24.
//

import Foundation

/** The actual response given by the `VocalAssistantDST` with respect to the provided user's request */
public enum VocalAssistantResponse {
    /** An error occurred processing user request. It contains the specific error message explaining the cause, which might be logged */
    case appError(errorMessage: String, answer: String, followUpQuestion: String)
    
    /** Classic response of the assistant, with just a sentence */
    case justAnswer(answer: String, followUpQuestion: String)
    
    /** The assistant found multiple matches of contacts and it asks the user to choose one among them */
    case askToChooseContact(contacts: [VocalAssistantContact], answer: String, followUpQuestion: String)
    
    /** The assistant found multiple matches of bank accounts and it asks the user to choose one among them */
    case askToChooseBankAccount(bankAccounts: [VocalAssistantBankAccount], answer: String, followUpQuestion: String)
    
    /** The user requested (and eventually confirmed) a specific in-app operation which now has to be performed   */
    case performInAppOperation(userIntent: UserIntentFrame, successMessage: String, failureMessage: String, answer: String, followUpQuestion: String)
    
    var answer: String {
        switch self {
        case .appError(_, let answer, _): return answer
        case .justAnswer(let answer, _): return answer
        case .askToChooseContact(_, let answer, _): return answer
        case .askToChooseBankAccount(_, let answer, _): return answer
        case .performInAppOperation(_, _, _, let answer, _): return answer
        }
    }
    
    var followUpQuestion: String {
        switch self {
        case .appError(_, _, let followUpQuestion): return followUpQuestion
        case .justAnswer(_, let followUpQuestion): return followUpQuestion
        case .askToChooseContact(_, _, let followUpQuestion): return followUpQuestion
        case .askToChooseBankAccount(_, _, let followUpQuestion): return followUpQuestion
        case .performInAppOperation(_, _, _, _, let followUpQuestion): return followUpQuestion
        }
    }
    
    var completeAnswer: String {
        let lastChar = self.answer.isEmpty ? "" : String(self.answer[self.answer.index(before: self.answer.endIndex)])
        return self.answer +
                (lastChar == "\n" ? "" : " ") + 
                self.followUpQuestion.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    static func checkBalanceOperation(bankAccount: VocalAssistantBankAccount) -> Self {
        return .performInAppOperation(
            userIntent: .checkBalance(
                bankAccount: bankAccount
            ),
            successMessage: "Here is what I found: the balance of your \(bankAccount.name) account is {amount}.",
            failureMessage: "I'm sorry, but I encountered an unexpected error while checking the balance of your \(bankAccount.name) account.",
            answer: "",
            followUpQuestion: "Is there anything else I can do for you?"
        )
    }
    
    static func checkTransactionsOperation(bankAccount: VocalAssistantBankAccount? = nil, contact: VocalAssistantContact? = nil, preAnswer: String? = nil) -> Self {
        return .performInAppOperation(
            userIntent: .checkLastTransactions(
                bankAccount: bankAccount,
                contact: contact
            ),
            successMessage: "\(preAnswer == nil ? "" : "\(preAnswer!) ")Here are your recent transactions\(bankAccount == nil ? "" : " with your \(bankAccount!.name) account")\(contact == nil ? "" : " involving \(contact!.description)"):\n{transactions}\n",
            failureMessage: "I'm sorry, but I encountered an unexpected error while retrieving your recent transactions\(bankAccount == nil ? "" : " with your \(bankAccount!.name) account")\(contact == nil ? "" : " involving \(contact!.description)").",
            answer: "",
            followUpQuestion: "Is there anything else I can do for you?"
        )
    }
    
    static func sendMoneyOperation(amount: VocalAssistantAmount, recipient: VocalAssistantContact, bankAccount: VocalAssistantBankAccount) -> Self {
        return .performInAppOperation(
            userIntent: .sendMoney(amount: amount, recipient: recipient, sourceAccount: bankAccount),
            successMessage: "Your \(amount.descriptionWithoutSign) amount has been successfully sent to \(recipient) using your \(bankAccount.name) account.",
            failureMessage: "I'm sorry, but I encountered an unexpected error while sending \(amount.descriptionWithoutSign) to \(recipient) using your \(bankAccount.name) account. Reason: {errorMsg}.",
            answer: "",
            followUpQuestion: "Is there anything else I can do for you?"
        )
    }
    
    static func requestMoneyOperation(amount: VocalAssistantAmount, sender: VocalAssistantContact, bankAccount: VocalAssistantBankAccount) -> Self {
        return .performInAppOperation(
            userIntent: .requestMoney(amount: amount, sender: sender, destinationAccount: bankAccount),
            successMessage: "Your \(amount.descriptionWithoutSign) amount has been successfully requested from \(sender) using your \(bankAccount.name) account.",
            failureMessage: "I'm sorry, but I encountered an unexpected error while requesting \(amount.descriptionWithoutSign) from \(sender) using your \(bankAccount.name) account. Reason: {errorMsg}.",
            answer: "",
            followUpQuestion: "Is there anything else I can do for you?"
        )
    }
    
    static func chooseBankAccount(among bankAccounts: [VocalAssistantBankAccount]) -> Self {
        return .askToChooseBankAccount(
            bankAccounts: bankAccounts,
            answer: "I've found multiple bank accounts that can match your request.",
            followUpQuestion: "Which one do you mean?"
        )
    }
    
    static func chooseContact(among contacts: [VocalAssistantContact]) -> Self {
        return .askToChooseContact(
            contacts: contacts,
            answer: "I've found multiple contacts matching your request.",
            followUpQuestion: "Who do you mean?"
        )
    }
    
    static func sendMoneyConfirmationQuestion(answer: String, amount: VocalAssistantAmount, recipient: VocalAssistantContact, sourceBankAccount: VocalAssistantBankAccount) -> Self {
        return .justAnswer(
            answer: answer,
            followUpQuestion: "You are going to send a \(amount.descriptionWithoutSign) amount to \(recipient) using your \(sourceBankAccount.name) account.\nDo you want to confirm?"
        )
    }
    
    static func requestMoneyConfirmationQuestion(answer: String, amount: VocalAssistantAmount, sender: VocalAssistantContact, destinationBankAccount: VocalAssistantBankAccount) -> Self {
        return .justAnswer(
            answer: answer,
            followUpQuestion: "You are going to request a \(amount.descriptionWithoutSign) amount from \(sender) using your \(destinationBankAccount.name) account.\nDo you want to confirm?"
        )
    }
}
