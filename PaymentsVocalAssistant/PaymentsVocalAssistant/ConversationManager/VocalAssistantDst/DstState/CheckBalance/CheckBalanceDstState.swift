//
//  CheckBalanceDstState.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 01/02/24.
//

import Foundation

class CheckBalanceDstState: DstState {
    var startSentence: String { return "" }
    var lastResponse: VocalAssistantResponse
    
    // check balance frame properties
    private let bankAccount: VocalAssistantBankAccount?
    internal let appContext: AppContext
    
    init(firstResponse: VocalAssistantResponse, appContext: AppContext, bankAccount: VocalAssistantBankAccount? = nil) {
        self.lastResponse = firstResponse
        self.bankAccount = bankAccount
        self.appContext = appContext
    }
    
    internal static let threshold = DefaultVocalAssistantConfig.uncertaintyThreshold
    
    static func from(
        probability: Float32,
        entities: [PaymentsEntity],
        previousState: DstState,
        appContext: AppContext
    ) -> (state: CheckBalanceDstState?, firstResponse: VocalAssistantResponse) {
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
                // don't create state
                let response: VocalAssistantResponse = .justAnswer(
                    answer: exceedingEntitiesErrorMsg,
                    followUpQuestion: "How can I help you, again?"
                )
                return (nil, response)
            }
            else {
                let response: VocalAssistantResponse = .justAnswer(
                    answer: exceedingEntitiesErrorMsg,
                    followUpQuestion: "Which bank account do you want to check the balance of?"
                )
                return (CheckBalanceDstState(firstResponse: response, appContext: appContext), response)
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
            
            let response: VocalAssistantResponse = .justAnswer(
                answer: "Just to confirm,",
                followUpQuestion: question
            )
            
            let unsureState = UnsureCheckBalanceDstState(
                lastResponse: response,
                previousState: previousState,
                possibleCurrency: selectedCurrency,
                possibleBankAccount: selectedBankAccount,
                appContext: appContext
            )
            return (unsureState, response)
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
                return (CheckBalanceDstState(firstResponse: response, appContext: appContext), response)
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
                return (CheckBalanceDstState(firstResponse: response, appContext: appContext, bankAccount: bankAccount), response)
            }
            else {
                // more than one bank accounts matched
                let response: VocalAssistantResponse = .askToChooseBankAccount(
                    bankAccounts: matchingBankAccounts,
                    answer: "I've found multiple bank accounts that can match your request.",
                    followUpQuestion: "Which account do you mean?"
                )
                return (CheckBalanceDstState(firstResponse: response, appContext: appContext), response)
            }
        }
        else {
            // none of the two has been specified -> ask user for specifying one
            let response: VocalAssistantResponse = .justAnswer(
                answer: "Ok,",
                followUpQuestion: "which account do you want to check the balance of?"
            )
            
            return (CheckBalanceDstState(firstResponse: response, appContext: appContext), response)
        }
    }
    
    func userExpressedNoneIntent(probability: Float32, entities: [PaymentsEntity], stateChanger: DstStateChanger) -> VocalAssistantResponse {
        // TODO: implement method
        return .appError(errorMessage: "", answer: "", followUpQuestion: "")
    }
    
    func userExpressedCheckBalanceIntent(probability: Float32, entities: [PaymentsEntity], stateChanger: DstStateChanger) -> VocalAssistantResponse {
        // TODO: implement method
        return .appError(errorMessage: "", answer: "", followUpQuestion: "")
    }
    
    func userExpressedCheckTransactionsIntent(probability: Float32, entities: [PaymentsEntity], stateChanger: DstStateChanger) -> VocalAssistantResponse {
        // TODO: implement method
        return .appError(errorMessage: "", answer: "", followUpQuestion: "")
    }
    
    func userExpressedSendMoneyIntent(probability: Float32, entities: [PaymentsEntity], stateChanger: DstStateChanger) -> VocalAssistantResponse {
        // TODO: implement method
        return .appError(errorMessage: "", answer: "", followUpQuestion: "")
    }
    
    func userExpressedRequestMoneyIntent(probability: Float32, entities: [PaymentsEntity], stateChanger: DstStateChanger) -> VocalAssistantResponse {
        // TODO: implement method
        return .appError(errorMessage: "", answer: "", followUpQuestion: "")
    }
    
    func userExpressedYesIntent(probability: Float32, stateChanger: DstStateChanger) -> VocalAssistantResponse {
        let response: VocalAssistantResponse = .justAnswer(
            answer: "Sorry, I didn't quite understand.",
            followUpQuestion: self.lastResponse.followUpQuestion
        )
        self.lastResponse = response
        return response
    }
    
    func userExpressedNoIntent(probability: Float32, stateChanger: DstStateChanger) -> VocalAssistantResponse {
        let response: VocalAssistantResponse = .justAnswer(
            answer: "Sorry, I didn't quite understand.",
            followUpQuestion: self.lastResponse.followUpQuestion
        )
        self.lastResponse = response
        return response
    }
}
