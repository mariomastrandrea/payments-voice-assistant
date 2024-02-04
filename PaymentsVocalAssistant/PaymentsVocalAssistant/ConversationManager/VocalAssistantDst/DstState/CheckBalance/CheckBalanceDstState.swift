//
//  CheckBalanceDstState.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 01/02/24.
//

import Foundation

class CheckBalanceDstState: DstState {
    var description: String {
        return "CheckBalanceDstState(bankAccount: \(bankAccount == nil ? "nil" : bankAccount!.description))"
    }

    var startSentence: String = ""
    var lastResponse: VocalAssistantResponse
    internal let appContext: AppContext
    
    // check balance frame properties
    private let bankAccount: VocalAssistantBankAccount?
    
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
        appContext: AppContext,
        comingFromSameState: Bool = false
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
                    followUpQuestion: previousState.lastResponse.followUpQuestion
                )
                return (nil, response)
            }
            else {
                let response: VocalAssistantResponse = .justAnswer(
                    answer: exceedingEntitiesErrorMsg,
                    followUpQuestion: "Which bank account do you want to check the balance of? Your bank accounts are: \(appContext.userBankAccounts.joined())"
                )
                return (CheckBalanceDstState(firstResponse: response, appContext: appContext), response)
            }
        }
        
        // retrieve the needed entities: currency and bank account (if any)
        // give prededence to the ones with probability greater or equal than the threshold, if any
        
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
                    followUpQuestion: "Which account do you want to check the balance of? Your bank accounts are: \(appContext.userBankAccounts.joined())"
                )
                return (CheckBalanceDstState(firstResponse: response, appContext: appContext), response)
            }
            else if matchingBankAccounts.count == 1 {
                let bankAccount = matchingBankAccounts[0]
                
                let response: VocalAssistantResponse = .checkBalanceOperation(bankAccount: bankAccount)
                return (CheckBalanceDstState(firstResponse: response, appContext: appContext, bankAccount: bankAccount), response)
            }
            else {
                // more than one bank accounts matched
                let response: VocalAssistantResponse = .chooseBankAccount(among: matchingBankAccounts)
                return (CheckBalanceDstState(firstResponse: response, appContext: appContext), response)
            }
        }
        else {
            if comingFromSameState {
                // none of the two has been specified -> inform about the misunderstanding and ask user to specify one
                let response: VocalAssistantResponse = .justAnswer(
                    answer: "Sorry, I didn't quite understant.",
                    followUpQuestion: "Which account do you want to check the balance of? Your bank accounts are: \(appContext.userBankAccounts.joined())"
                )
                
                return (CheckBalanceDstState(firstResponse: response, appContext: appContext), response)
            }
            else {
                // none of the two has been specified -> confirm the intent and ask user to specify one
                let response: VocalAssistantResponse = .justAnswer(
                    answer: "Ok.",
                    followUpQuestion: "Which account do you want to check the balance of? Your bank accounts are: \(appContext.userBankAccounts.joined())"
                )
                
                return (CheckBalanceDstState(firstResponse: response, appContext: appContext), response)
            }
        }
    }
    
    func userExpressedNoneIntent(entities: [PaymentsEntity], stateChanger: DstStateChanger) -> VocalAssistantResponse {
        // (re-use the same code)
        // the state might stay the same, but still a new instance is created
        let (newState, response) = CheckBalanceDstState.from(
            probability: 1.0,    // (I want to keep this state)
            entities: entities,
            previousState: self,
            appContext: self.appContext,
            comingFromSameState: true
        )
        
        if let newState = newState {
            stateChanger.changeDstState(to: newState)
        }
        
        return response
    }
    
    func userExpressedCheckBalanceIntent(probability: Float32, entities: [PaymentsEntity], stateChanger: DstStateChanger) -> VocalAssistantResponse {
        // (re-use the same code)
        // the state might stay the same, but still a new instance is created
        let (newState, response) = CheckBalanceDstState.from(
            probability: probability,
            entities: entities,
            previousState: self,
            appContext: self.appContext
        )
        
        if let newState = newState {
            stateChanger.changeDstState(to: newState)
        }
        else {
            self.lastResponse = response
        }
        
        return response
    }
    
    func userExpressedCheckTransactionsIntent(probability: Float32, entities: [PaymentsEntity], stateChanger: DstStateChanger) -> VocalAssistantResponse {
        let (newState, response) = CheckTransactionsDstState.from(
            probability: probability,
            entities: entities,
            previousState: self,
            appContext: self.appContext
        )
        
        if let newState = newState {
            stateChanger.changeDstState(to: newState)
        }
        else {
            self.lastResponse = response
        }
        
        return response
    }
    
    func userExpressedSendMoneyIntent(probability: Float32, entities: [PaymentsEntity], stateChanger: DstStateChanger) -> VocalAssistantResponse {
        let (newState, response) = SendMoneyDstState.from(
            probability: probability,
            entities: entities,
            previousState: self,
            appContext: self.appContext
        )
        
        if let newState = newState {
            stateChanger.changeDstState(to: newState)
        }
        else {
            self.lastResponse = response
        }
        
        return response
    }
    
    func userExpressedRequestMoneyIntent(probability: Float32, entities: [PaymentsEntity], stateChanger: DstStateChanger) -> VocalAssistantResponse {
        let (newState, response) = RequestMoneyDstState.from(
            probability: probability,
            entities: entities,
            previousState: self,
            appContext: self.appContext
        )
        
        if let newState = newState {
            stateChanger.changeDstState(to: newState)
        }
        else {
            self.lastResponse = response
        }
        
        return response
    }
    
    func userExpressedYesIntent(probability: Float32, stateChanger: DstStateChanger) -> VocalAssistantResponse {
        if self.bankAccount != nil {
            // task is already completed -> go back to NoDstState
            let response: VocalAssistantResponse = .justAnswer(
                answer: "Ok.",
                followUpQuestion: "Go ahead with your request, I'm here to help you."
            )
            let newState = NoDstState(appContext: self.appContext, firstResponse: response)
            stateChanger.changeDstState(to: newState)
            
            return response
        }
        
        let response: VocalAssistantResponse = .justAnswer(
            answer: "Sorry, I didn't quite understand.",
            followUpQuestion: self.lastResponse.followUpQuestion
        )
        self.lastResponse = response
        return response
    }
    
    func userExpressedNoIntent(probability: Float32, stateChanger: DstStateChanger) -> VocalAssistantResponse {
        if self.bankAccount != nil {
            // task is already completed -> go back to NoDstState
            let response: VocalAssistantResponse = .justAnswer(
                answer: "Ok.",
                followUpQuestion: "If you have any other request, I'm here to help you."
            )
            let newState = NoDstState(appContext: self.appContext, firstResponse: response)
            stateChanger.changeDstState(to: newState)
            
            return response
        }
        
        let response: VocalAssistantResponse = .justAnswer(
            answer: "Sorry, I didn't quite understand.",
            followUpQuestion: self.lastResponse.followUpQuestion
        )
        self.lastResponse = response
        return response
    }
}
