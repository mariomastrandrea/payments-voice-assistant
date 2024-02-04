//
//  UnsureCheckBalanceDstState.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 01/02/24.
//

import Foundation

class UnsureCheckBalanceDstState: CheckBalanceDstState {
    override var description: String {
        return "UnsureCheckBalanceDstState(possibleCurrency: \(possibleCurrency == nil ? "nil" : possibleCurrency!.reconstructedEntity), possibleBankAccount: \(possibleBankAccount == nil ? "nil" : possibleBankAccount!.reconstructedEntity))"
    }
    
    private var previousState: DstState
    private var possibleCurrency: PaymentsEntity?
    private var possibleBankAccount: PaymentsEntity?
    
    init(lastResponse: VocalAssistantResponse, previousState: DstState, possibleCurrency: PaymentsEntity?, possibleBankAccount: PaymentsEntity?, appContext: AppContext) {
        self.previousState = previousState
        self.possibleCurrency = possibleCurrency
        self.possibleBankAccount = possibleBankAccount
        
        super.init(firstResponse: lastResponse, appContext: appContext)
    }
    
    override func userExpressedNoneIntent(entities: [PaymentsEntity], stateChanger: DstStateChanger) -> VocalAssistantResponse {
        
        let response: VocalAssistantResponse = .justAnswer(
            answer: "Sorry, I cannot help you with that.",
            followUpQuestion: self.previousState.lastResponse.followUpQuestion
        )
        
        // come back to the previous state and update its last response
        stateChanger.changeDstState(to: self.previousState)
        self.previousState.lastResponse = response
        
        return response
    }
    
    override func userExpressedYesIntent(probability: Float32, stateChanger: DstStateChanger) -> VocalAssistantResponse {
        // there is one or two unsure entities, or simply the intent was unsure
        
        let matchingBankAccounts = self.appContext.userBankAccounts.filter { account in
            (possibleCurrency != nil ? account.currency.match(with: possibleCurrency!.reconstructedEntity) : true) &&
            (possibleBankAccount != nil ? account.match(with: possibleBankAccount!.reconstructedEntity) : true)
        }
        
        if matchingBankAccounts.isEmpty {
            let response: VocalAssistantResponse = .justAnswer(
                answer: "Ok, but I didn't find any bank account matching your request.",
                followUpQuestion: "Which account do you want to check the balance of? Your bank accounts are: \(appContext.userBankAccounts.joined())"
            )
            // go to 'sure' CheckBalance state
            let newState = CheckBalanceDstState(firstResponse: response, appContext: self.appContext)
            stateChanger.changeDstState(to: newState)
            
            return response
        }
        else if matchingBankAccounts.count == 1 {
            let bankAccount = matchingBankAccounts[0]
            
            // change state to the 'sure' one
            // and return the operation response
            let response: VocalAssistantResponse = .checkBalanceOperation(bankAccount: bankAccount)
            
            let newState = CheckBalanceDstState(firstResponse: response, appContext: self.appContext, bankAccount: bankAccount)
            stateChanger.changeDstState(to: newState)
            
            return response
        }
        else {
            let response: VocalAssistantResponse
            
            if self.possibleCurrency == nil && self.possibleBankAccount == nil {
                // user didn't mention any detail about the bank account to check
                response = .justAnswer(
                    answer: "Ok.",
                    followUpQuestion: "Which account do you want to check the balance of? Your bank accounts are: \(appContext.userBankAccounts.joined())"
                )
            }
            else {
                // more than one bank account matched -> ask to choose
                response = .chooseBankAccount(among: matchingBankAccounts)
            }
        
            // go to 'sure' state
            let newState = CheckBalanceDstState(firstResponse: response, appContext: self.appContext)
            stateChanger.changeDstState(to: newState)
            
            return response
        }
    }
    
    override func userExpressedNoIntent(probability: Float32, stateChanger: DstStateChanger) -> VocalAssistantResponse {
        let response: VocalAssistantResponse = .justAnswer(
            answer: "Ok, never mind.",
            followUpQuestion: self.previousState.lastResponse.followUpQuestion
        )
        
        // come back to the previous state and update its last response
        stateChanger.changeDstState(to: self.previousState)
        self.previousState.lastResponse = response
        
        return response
    }
}
