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
        return (self.answer + " " + self.followUpQuestion).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
