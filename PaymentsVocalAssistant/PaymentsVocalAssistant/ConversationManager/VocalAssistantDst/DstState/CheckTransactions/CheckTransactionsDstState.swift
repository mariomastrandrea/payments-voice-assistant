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
    
    // check transactions frame properties
    private let bankAccount: VocalAssistantBankAccount?
    private let contact: VocalAssistantContact?
    internal let appContext: AppContext
    
    
    init(firstResponse: VocalAssistantResponse, appContext: AppContext, bankAccount: VocalAssistantBankAccount? = nil, contact: VocalAssistantContact? = nil) {
        self.lastResponse = firstResponse
        self.bankAccount = bankAccount
        self.contact = contact
        self.appContext = appContext
    }
    
    internal static let threshold = DefaultVocalAssistantConfig.uncertaintyThreshold

    static func from(
        probability: Float32,
        entities: [PaymentsEntity],
        previousState: DstState,
        appContext: AppContext,
        comingFromSameState: Bool = false
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
            
        }
        
        
        
        // TODO: implement method
        return (nil, .appError(errorMessage: "todo", answer: "todo", followUpQuestion: "todo"))
    }
    
    func userExpressedNoneIntent(entities: [PaymentsEntity], stateChanger: DstStateChanger) -> VocalAssistantResponse {
        // TODO: implement method
        return .appError(errorMessage: "todo", answer: "todo", followUpQuestion: "todo")
    }
    
    func userExpressedCheckBalanceIntent(probability: Float32, entities: [PaymentsEntity], stateChanger: DstStateChanger) -> VocalAssistantResponse {
        // TODO: implement method
        return .appError(errorMessage: "todo", answer: "todo", followUpQuestion: "todo")
    }
    
    func userExpressedCheckTransactionsIntent(probability: Float32, entities: [PaymentsEntity], stateChanger: DstStateChanger) -> VocalAssistantResponse {
        // TODO: implement method
        return .appError(errorMessage: "todo", answer: "todo", followUpQuestion: "todo")
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
        // TODO: implement method
        return .appError(errorMessage: "todo", answer: "todo", followUpQuestion: "todo")
    }
    
    func userExpressedNoIntent(probability: Float32, stateChanger: DstStateChanger) -> VocalAssistantResponse {
        // TODO: implement method
        return .appError(errorMessage: "todo", answer: "todo", followUpQuestion: "todo")
    }
}
