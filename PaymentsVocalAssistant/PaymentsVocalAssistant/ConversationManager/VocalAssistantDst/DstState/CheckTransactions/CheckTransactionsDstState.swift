//
//  CheckTransactionsDstState.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 02/02/24.
//

import Foundation

class CheckTransactionsDstState: DstState {
    var description: String {
        return "CheckTransactionsDstState(bankAccount: \(self.bankAccount == nil ? "nil" : self.bankAccount!.description), contact: \(self.contact == nil ? "nil" : self.contact!.description))"
    }
    
    var startSentence: String = ""
    var lastResponse: VocalAssistantResponse
    internal let appContext: AppContext
    
    // check transactions frame properties
    private let bankAccount: VocalAssistantBankAccount?
    private let contact: VocalAssistantContact?
    
    
    init(firstResponse: VocalAssistantResponse, appContext: AppContext, bankAccount: VocalAssistantBankAccount? = nil, contact: VocalAssistantContact? = nil) {
        self.lastResponse = firstResponse
        self.appContext = appContext
        self.bankAccount = bankAccount
        self.contact = contact
    }
    
    internal static let threshold = DefaultVocalAssistantConfig.uncertaintyThreshold

    static func from(
        probability: Float32,
        entities: [PaymentsEntity],
        previousState: DstState,
        appContext: AppContext
    ) -> (state: CheckTransactionsDstState?, firstResponse: VocalAssistantResponse) {
        // look for any bank(s) and user(s) entities
        let bankEntities = entities.filter({ $0.type == .bank })
        let userEntities = entities.filter({ $0.type == .user })
        
        // check if more entities than needed have been specified
        let numConfidentBanks = bankEntities.filter { $0.entityProbability >= threshold }.count
        let numConfidentUsers = userEntities.filter { $0.entityProbability >= threshold }.count
        var exceedingEntitiesErrorMsg = ""

        if numConfidentBanks > 1 {
            // more than one bank account has been specified
            exceedingEntitiesErrorMsg = "Please specify at most one bank account"
        }
        
        if numConfidentUsers > 1 {
            // more than one user has been specified
            exceedingEntitiesErrorMsg = exceedingEntitiesErrorMsg.isEmpty ? "Please specify at most one contact" : " and at most one contact"
        }
        
        if exceedingEntitiesErrorMsg.isNotEmpty {
            // more entities than needed have been specified
            exceedingEntitiesErrorMsg += " to check your last transactions."
            
            if probability < threshold {
                // don't create state
                let response: VocalAssistantResponse = .justAnswer(
                    answer: exceedingEntitiesErrorMsg,
                    followUpQuestion: "How can I help you, again?"
                )
                return (nil, response)
            }
            else {
                // create empty state and perform check transactions operation with no entities
                let response: VocalAssistantResponse = .performInAppOperation(
                    userIntent: .checkLastTransactions(
                        bankAccount: nil,
                        contact: nil
                    ),
                    successMessage: "\(exceedingEntitiesErrorMsg) Here are your recent transactions:\n{transactions}\n",
                    failureMessage: "I'm sorry, but I encountered an unexpected error while retrieving your recent transactions.",
                    answer: "",
                    followUpQuestion: "Is there anything else I can do for you?"
                )
                
                return (CheckTransactionsDstState(firstResponse: response, appContext: appContext), response)
            }
        }
        
        // retrieve the needed entities: bank account and/or user (if any)
        // give prededence to the ones with probability greater or equal than the threshold, if any
        
        var selectedBankAccount = bankEntities.first { $0.entityProbability >= threshold }
        var selectedBankAccountUnsure = false
        
        if selectedBankAccount == nil {
            // select the first with entity probability < threhsold (if any)
            selectedBankAccount = bankEntities.first
            if selectedBankAccount != nil {
                selectedBankAccountUnsure = true
            }
        }
        
        var selectedContact = userEntities.first { $0.entityProbability >= threshold }
        var selectedContactUnsure = false
        
        if selectedContact == nil {
            // select the first with entity probability < threhsold (if any)
            selectedContact = userEntities.first
            if selectedContact != nil {
                selectedContactUnsure = true
            }
        }
        
        // check if there is any probability below the threshold among the chosen intent and entities
        if probability < threshold || selectedBankAccountUnsure || selectedContactUnsure {
            // something is not sure
            var question = "are you requesting to check your recent transactions"
            
            if selectedBankAccountUnsure, let bankAccount = selectedBankAccount {
                question += " for your \(bankAccount.reconstructedEntity) account"
            }
            
            if selectedContactUnsure, let contact = selectedContact {
                question += " involving \(contact.reconstructedEntity)"
            }
            
            question += "?"
            
            let response: VocalAssistantResponse = .justAnswer(
                answer: "Just to confirm,",
                followUpQuestion: question
            )
            
            // return the unsure state
            let unsureState = UnsureCheckTransactionsDstState(
                lastResponse: response,
                previousState: previousState,
                possibleBankAccount: selectedBankAccount,
                possibleContact: selectedContact,
                appContext: appContext
            )
            
            return (unsureState, response)
        }
        
        // * every specified info is 'sure' here *
        // now look for matching entities
        
        var matchingBankAccounts: [VocalAssistantBankAccount] = []
        var matchingContacts: [VocalAssistantContact] = []
        
        if let possibleBankAccount = selectedBankAccount {
            // the bank account has been mentioned
            matchingBankAccounts = appContext.userBankAccounts.filter { bankAccount in
                bankAccount.match(with: possibleBankAccount.reconstructedEntity)
            }
        }
        
        if let possibleContact = selectedContact {
            // the contact has been mentioned
            matchingContacts = appContext.userContacts.keepAndOrderJustTheOnesSimilar(to: possibleContact.reconstructedEntity)
        }
        
        // (priority to the contacts)
        
        if matchingContacts.count > 1 {
            // more than one contact matched -> create state and ask to choose one
            let response: VocalAssistantResponse = .chooseContact(among: matchingContacts)
            
            // save the bank account only if just one matches
            let eventualMatchingBankAccount = matchingBankAccounts.count == 1 ? matchingBankAccounts[0] : nil
            
            let newState = CheckTransactionsDstState(firstResponse: response, appContext: appContext, bankAccount: eventualMatchingBankAccount)
            
            return (newState, response)
        }
        
        if matchingBankAccounts.count > 1 {
            // more than one bank account matched -> create state and ask to choose one
            let response: VocalAssistantResponse = .chooseBankAccount(among: matchingBankAccounts)
            
            // save the contact only if just one matches
            let eventualMatchingContact = matchingContacts.count == 1 ? matchingContacts[0] : nil
            
            let newState = CheckTransactionsDstState(firstResponse: response, appContext: appContext, contact: eventualMatchingContact)
            
            return (newState, response)
        }
        
        // here we can proceed with the in-app operation
        
        var matchingNotFoundMessages = [String]()
        
        if selectedContact != nil && matchingContacts.isEmpty {
            matchingNotFoundMessages.append("I didn't find any contact matching your request")
        }
        
        if selectedBankAccount != nil && matchingBankAccounts.isEmpty {
            matchingNotFoundMessages.append("I didn't find any bank account matching your request")
        }
        
        var matchingNotFoundMessage = matchingNotFoundMessages.joined(separator: " and ")
        if matchingNotFoundMessage.isNotEmpty { matchingNotFoundMessage += "." }
        
        let eventualMatchingBankAccount = matchingBankAccounts[safe: 0]
        let eventualMatchingContact = matchingContacts[safe: 0]
        
        // create check transaction operation response and create corresponding state
        let response: VocalAssistantResponse = .checkTransactionsOperation(
            bankAccount: eventualMatchingBankAccount,
            contact: eventualMatchingContact,
            preAnswer: matchingNotFoundMessage
        )
        
        let newState = CheckTransactionsDstState(
            firstResponse: response,
            appContext: appContext,
            bankAccount: eventualMatchingBankAccount,
            contact: eventualMatchingContact
        )
        
        return (newState, response)
    }
    
    func userExpressedNoneIntent(entities: [PaymentsEntity], stateChanger: DstStateChanger) -> VocalAssistantResponse {
        // (the checkTransactions intent is not waiting for any entity to be specified)
        let response: VocalAssistantResponse = .justAnswer(
            answer: "Sorry, I didn't quite understand.",
            followUpQuestion: self.lastResponse.followUpQuestion
        )
        self.lastResponse = response
        return response
    }
    
    func userExpressedCheckBalanceIntent(probability: Float32, entities: [PaymentsEntity], stateChanger: DstStateChanger) -> VocalAssistantResponse {
        let (newCheckBalanceState, response) = CheckBalanceDstState.from(
            probability: probability,
            entities: entities,
            previousState: self,
            appContext: self.appContext
        )
        
        if let newState = newCheckBalanceState {
            stateChanger.changeDstState(to: newState)
        }
        else {
            self.lastResponse = response
        }
        
        return response
    }
    
    func userExpressedCheckTransactionsIntent(probability: Float32, entities: [PaymentsEntity], stateChanger: DstStateChanger) -> VocalAssistantResponse {
        // (re-use the same code)
        // the state might stay the same, but still a new instance is created
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
        // TODO: implement method
        return .appError(errorMessage: "todo", answer: "todo", followUpQuestion: "todo")
    }
    
    func userExpressedRequestMoneyIntent(probability: Float32, entities: [PaymentsEntity], stateChanger: DstStateChanger) -> VocalAssistantResponse {
        // TODO: implement method
        return .appError(errorMessage: "todo", answer: "todo", followUpQuestion: "todo")
    }
    
    func userExpressedYesIntent(probability: Float32, stateChanger: DstStateChanger) -> VocalAssistantResponse {
        // task is already completed -> go back to NoDstState
        let response: VocalAssistantResponse = .justAnswer(
            answer: "Ok.",
            followUpQuestion: "Go ahead with your request, I'm here to help you."
        )
        let newState = NoDstState(appContext: self.appContext, firstResponse: response)
        stateChanger.changeDstState(to: newState)
        
        return response
    }
    
    func userExpressedNoIntent(probability: Float32, stateChanger: DstStateChanger) -> VocalAssistantResponse {
        // task is already completed -> go back to NoDstState
        let response: VocalAssistantResponse = .justAnswer(
            answer: "Ok.",
            followUpQuestion: "If you have any other request, I'm here to help you."
        )
        let newState = NoDstState(appContext: self.appContext, firstResponse: response)
        stateChanger.changeDstState(to: newState)
        
        return response
    }
}
