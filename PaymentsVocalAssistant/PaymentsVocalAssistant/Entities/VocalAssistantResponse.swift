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
    case appError(errorMessage: String, followUpQuestion: String)
    
    /** Classic response of the assistant, with just a sentence */
    case followUpQuestion(question: String)
    
    /** The assistant found multiple matches of contacts and it asks the user to choose one among them */
    case askToChooseContact(contacts: [VocalAssistantContact], question: String)
    
    /** The assistant found multiple matches of bank accounts and it asks the user to choose one among them */
    case askToChooseBankAccount(bankAccounts: [VocalAssistantBankAccount], question: String)
    
    /** The user requested (and eventually confirmed) a specific in-app operation which now has to be performed   */
    case performInAppOperation(answer: String, userIntent: UserIntentFrame, successMessage: String, failureMessage: String)
    
    var textAnswer: String {
        switch self {
        case .appError(_, let followUpQuestion): return followUpQuestion
        case .followUpQuestion(let question): return question
        case .askToChooseContact(_, let question): return question
        case .askToChooseBankAccount(_, let question): return question
        case .performInAppOperation(let answer, _, _, _): return answer
        }
    }
}
