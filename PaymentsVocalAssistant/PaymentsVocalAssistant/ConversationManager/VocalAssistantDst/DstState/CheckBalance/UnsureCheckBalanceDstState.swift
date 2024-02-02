//
//  UnsureCheckBalanceDstState.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 01/02/24.
//

import Foundation

class UnsureCheckBalanceDstState: CheckBalanceDstState {
    private var previousState: DstState
    private var possibleCurrency: PaymentsEntity?
    private var possibleBankAccount: PaymentsEntity?
    
    init(lastResponse: VocalAssistantResponse, previousState: DstState, possibleCurrency: PaymentsEntity?, possibleBankAccount: PaymentsEntity?, appContext: AppContext) {
        self.previousState = previousState
        self.possibleCurrency = possibleCurrency
        self.possibleBankAccount = possibleBankAccount
        
        super.init(firstResponse: lastResponse, appContext: appContext)
    }
    
    override func userExpressedNoneIntent(probability: Float32, entities: [PaymentsEntity], stateChanger: DstStateChanger) -> VocalAssistantResponse {
        
        let response: VocalAssistantResponse = .justAnswer(
            answer: "Sorry, I cannot help you with that.",
            followUpQuestion: self.previousState.lastResponse.followUpQuestion
        )
        
        // come back to the previous state and update its last response
        stateChanger.changeDstState(to: self.previousState)
        self.previousState.lastResponse = response
        
        return response
    }
    
    override func userExpressedCheckBalanceIntent(probability: Float32, entities: [PaymentsEntity], stateChanger: DstStateChanger) -> VocalAssistantResponse {
        let threshold = CheckBalanceDstState.threshold
        
        // search for any currrency(ies) and bank account(s)
        let currenciesEntities = entities.filter { $0.type == .currency }
        let bankAccountsEntities = entities.filter { $0.type == .bank }
        
        // check if more entities than needed have been specified
        let numConfidentCurrencies = currenciesEntities.filter { $0.entityProbability >= threshold }.count
        let numConfidentBankAccounts = bankAccountsEntities.filter { $0.entityProbability >= threshold }.count
        var exceedingEntitiesErrorMsg = ""
        
        if numConfidentCurrencies > 1 {
            // more than one currency has been specified
            exceedingEntitiesErrorMsg = "Please specify just one currency"
        }
        
        if numConfidentBankAccounts > 1 {
            // more than one bank account has been specified
            exceedingEntitiesErrorMsg = exceedingEntitiesErrorMsg.isEmpty ?
                "Please specify just one bank account" : " or just one bank account"
        }
        
        if exceedingEntitiesErrorMsg.isNotEmpty {
            // more entities than needed have been specified
            exceedingEntitiesErrorMsg += " to check your balance."
            
            if probability < threshold {
                // don't change state, still unsure
                let response: VocalAssistantResponse = .justAnswer(
                    answer: exceedingEntitiesErrorMsg,
                    followUpQuestion: "How can I help you, again?"
                )
                self.lastResponse = response
                return response
            }
            else {
                // change to the 'sure' state
                let response: VocalAssistantResponse = .justAnswer(
                    answer: exceedingEntitiesErrorMsg,
                    followUpQuestion: "Which bank account do you want to check the balance of?"
                )
                let newState = CheckBalanceDstState(firstResponse: response, appContext: appContext)
                stateChanger.changeDstState(to: newState)
                
                return response
            }
        }
        
        // retrieve the needed entities: currency and bank account
        // give prededence to the one with probability greater or equal than the threshold, if any
        
        var selectedCurrency = currenciesEntities.first { $0.entityProbability >= threshold }
        var selectedCurrencyUnsure = false
        
        if selectedCurrency == nil {
            // select the first with entity probability < threhsold (if any)
            selectedCurrency = currenciesEntities.first
            if selectedCurrency != nil {
                selectedCurrencyUnsure = true
            }
        }
        
        var selectedBankAccount = bankAccountsEntities.first { $0.entityProbability >= threshold }
        var selectedBankAccountUnsure = false
        
        if selectedBankAccount == nil {
            // select the first with entity probability < threhsold (if any)
            selectedBankAccount = bankAccountsEntities.first
            if selectedBankAccount != nil {
                selectedBankAccountUnsure = true
            }
        }
        
        // check if there is any probability below the threshold among the chosen intent and entities
        if probability < threshold || selectedCurrencyUnsure || selectedBankAccountUnsure {
            // something is not sure
            var question = "are you requesting to check your balance"
            
            if selectedCurrencyUnsure, let currency = selectedCurrency {
                question += " in \(currency.reconstructedEntity)"
            }
            
            if selectedBankAccountUnsure, let bankAccount = selectedBankAccount {
                let accountDescription = bankAccount.reconstructedEntity == "default" || bankAccount.reconstructedEntity == "primary" ? " for your \(bankAccount.reconstructedEntity) account" : " at \(bankAccount.reconstructedEntity)"
                question += accountDescription
            }
            
            question += "?"
            
            // do not change state (keep the unsure state), just update the properties
            let response: VocalAssistantResponse = .justAnswer(
                answer: "Just to confirm,",
                followUpQuestion: question
            )
            self.lastResponse = response
            self.possibleCurrency = selectedCurrency
            self.possibleBankAccount = selectedBankAccount
            
            return response
        }
        
        // * every specified info is 'sure' here *
        
        if selectedCurrency != nil || selectedBankAccount != nil {
            // at least one between currency and account has been specified -> everything needed is specified
            
            // look for any matching user bank account
            let matchingBankAccounts = appContext.userBankAccounts.filter { account in
                (selectedCurrency != nil ? account.currency.match(with: selectedCurrency!.reconstructedEntity) : true) &&
                (selectedBankAccount != nil ? account.match(with: selectedBankAccount!.reconstructedEntity) : true)
            }
            
            if matchingBankAccounts.count == 0 {
                let response: VocalAssistantResponse = .justAnswer(
                    answer: "Sorry, I didn't find any bank account matching your request.",
                    followUpQuestion: "Which account do you want to check the balance of?"
                )
                let newState = CheckBalanceDstState(firstResponse: response, appContext: appContext)
                stateChanger.changeDstState(to: newState)
                return response
            }
            else if matchingBankAccounts.count == 1 {
                let bankAccount = matchingBankAccounts[0]
                
                let response: VocalAssistantResponse = .performInAppOperation(
                    userIntent: .checkBalance(
                        bankAccount: bankAccount,
                        successMessage: "Here is what I found: the balance of your \(bankAccount.name) account is {amount}.",
                        failureMessage: "I'm sorry, but I encountered an error while checking the balance."
                    ),
                    answer: "Ok, I'll check the balance of your \(bankAccount.name) account for you.",
                    followUpQuestion: "Is there anything else I can do for you?"
                )
                let newState = CheckBalanceDstState(firstResponse: response, appContext: appContext, bankAccount: bankAccount)
                stateChanger.changeDstState(to: newState)
                
                return response
            }
            else {
                // more than one bank accounts matched
                let response: VocalAssistantResponse = .askToChooseBankAccount(
                    bankAccounts: matchingBankAccounts,
                    answer: "I've found multiple bank accounts that can match your request.",
                    followUpQuestion: "Which account do you mean?"
                )
                let newState = CheckBalanceDstState(firstResponse: response, appContext: appContext)
                stateChanger.changeDstState(to: newState)
                
                return response
            }
        }
        else {
            // none of the two has been specified -> ask user to specify one and change to the 'sure' state
            let response: VocalAssistantResponse = .justAnswer(
                answer: "Ok,",
                followUpQuestion: "which account do you want to check the balance of?"
            )
            let newState = CheckBalanceDstState(firstResponse: response, appContext: appContext)
            stateChanger.changeDstState(to: newState)
            
            return response
        }
    }
    
    override func userExpressedYesIntent(probability: Float32, stateChanger: DstStateChanger) -> VocalAssistantResponse {
        // there is at least one unsure entity
        
        let matchingBankAccounts = self.appContext.userBankAccounts.filter { account in
            (possibleCurrency != nil ? account.currency.match(with: possibleCurrency!.reconstructedEntity) : true) &&
            (possibleBankAccount != nil ? account.match(with: possibleBankAccount!.reconstructedEntity) : true)
        }
        
        if matchingBankAccounts.isEmpty {
            let response: VocalAssistantResponse = .justAnswer(
                answer: "Ok, but I didn't find any bank account matching your request.",
                followUpQuestion: "Which account do you want to check the balance of?"
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
            let response: VocalAssistantResponse = .performInAppOperation(
                userIntent: .checkBalance(
                    bankAccount: bankAccount,
                    successMessage: "Here is what I found: the balance of your \(bankAccount.name) account is {amount}.",
                    failureMessage: "I'm sorry, but I encountered an error while checking the balance."
                ),
                answer: "Ok, I'll check the balance of your \(bankAccount.name) account for you.",
                followUpQuestion: "Is there anything else I can do for you?"
            )
            
            let newState = CheckBalanceDstState(firstResponse: response, appContext: self.appContext, bankAccount: bankAccount)
            stateChanger.changeDstState(to: newState)
            
            return response
        }
        else {
            // more than one bank account matched -> change state and ask to choose
            let response: VocalAssistantResponse = .askToChooseBankAccount(
                bankAccounts: matchingBankAccounts,
                answer: "I've found multiple bank accounts that can match your request.",
                followUpQuestion: "Which account do you mean?"
            )
            
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
