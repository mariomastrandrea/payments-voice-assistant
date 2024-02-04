//
//  SendMoneyDstState.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 03/02/24.
//

import Foundation

class SendMoneyDstState: DstState {
    var description: String {
        return "SendMoneyDstState(amount: \(self.amount?.description ?? "nil"), receiver: \(self.recipient?.description ?? "nil"), bankAccount: \(self.bankAccount?.description ?? "nil"))"
    }
    
    var startSentence: String = ""
    var lastResponse: VocalAssistantResponse
    internal let appContext: AppContext
    
    // send money frame properties
    private let amount: VocalAssistantAmount?
    private let recipient: VocalAssistantContact?
    private let bankAccount: VocalAssistantBankAccount?

    
    init(firstResponse: VocalAssistantResponse, appContext: AppContext, amount: VocalAssistantAmount? = nil, recipient: VocalAssistantContact? = nil, bankAccount: VocalAssistantBankAccount? = nil) {
        self.lastResponse = firstResponse
        self.appContext = appContext
        self.amount = amount
        self.recipient = recipient
        self.bankAccount = bankAccount
    }
    
    internal static let threshold = DefaultVocalAssistantConfig.uncertaintyThreshold

    static func from(
        probability: Float32,
        entities: [PaymentsEntity],
        previousState: DstState,
        appContext: AppContext
    ) -> (state: SendMoneyDstState?, firstResponse: VocalAssistantResponse) {
        // look for amount, user and bank entities
        let amountEntities = entities.filter { $0.type == .amount }
        let userEntities   = entities.filter { $0.type == .user }
        let bankEntities   = entities.filter { $0.type == .bank }
        
        // check if more entities than needed have been specified
        let numConfidentAmounts = amountEntities.filter { $0.entityProbability >= threshold }.count
        let numConfidentUsers   =   userEntities.filter { $0.entityProbability >= threshold }.count
        let numConfidentBanks   =   bankEntities.filter { $0.entityProbability >= threshold }.count
        var exceedingEntitiesErrorMsg = ""
        
        if numConfidentAmounts > 1 {
            // more than one amount has been specified by the user
            exceedingEntitiesErrorMsg = "Please specify just one amount"
        }
        
        if numConfidentUsers > 1 {
            // more than one contact has been specified by the user
            exceedingEntitiesErrorMsg += exceedingEntitiesErrorMsg.isEmpty ? "Please specify just one receiver" : " and just one receiver"
        }
        
        if numConfidentBanks > 1 {
            // more than one bank has been specified by the user
            exceedingEntitiesErrorMsg += exceedingEntitiesErrorMsg.isEmpty ? "Please specify just one bank account" : " and just one bank account"
        }
        
        if exceedingEntitiesErrorMsg.isNotEmpty {
            // more entities than needed have been specified
            exceedingEntitiesErrorMsg += " to send some money."
            
            if probability < threshold {
                // intent is not 'sure' -> do not create new state
                let response: VocalAssistantResponse = .justAnswer(
                    answer: exceedingEntitiesErrorMsg,
                    followUpQuestion: previousState.lastResponse.followUpQuestion
                )
                
                return (nil, response)
            }
            else {
                // intent is 'sure' -> create state, and ask for the amount
                let response: VocalAssistantResponse = .justAnswer(
                    answer: exceedingEntitiesErrorMsg,
                    followUpQuestion: "How much do you want to send?"
                )
                
                let newState = SendMoneyDstState(firstResponse: response, appContext: appContext)
                return (newState, response)
            }
        }
        
        // retrieve the needed entities: amount, contact(recipient) and bank account
        // give prededence to the ones with probability greater or equal than the threshold, if any
        
        var selectedAmount = amountEntities.first { $0.entityProbability >= threshold }
        var selectedAmountUnsure = false
        
        if selectedAmount == nil {
            // select the first with entity probability < threhsold (if any)
            selectedAmount = amountEntities.first
            if selectedAmount != nil {
                selectedAmountUnsure = true
            }
        }
        
        var selectedRecipient = userEntities.first { $0.entityProbability >= threshold }
        var selectedRecipientUnsure = false
        
        if selectedRecipient == nil {
            // select the first with entity probability < threhsold (if any)
            selectedRecipient = userEntities.first
            if selectedRecipient != nil {
                selectedRecipientUnsure = true
            }
        }
        
        var selectedBankAccount = bankEntities.first { $0.entityProbability >= threshold }
        var selectedBankAccountUnsure = false
        
        if selectedBankAccount == nil {
            // select the first with entity probability < threshold (if any)
            selectedBankAccount = bankEntities.first
            if selectedBankAccount != nil {
                selectedBankAccountUnsure = true
            }
        }
        
        // check if there is any probability below the threshold among the chosen intent and entities
        if probability < threshold || selectedAmountUnsure || selectedRecipientUnsure || selectedBankAccountUnsure {
            // something is not sure
            var question = "are you requesting to send"
            
            if selectedAmountUnsure, let amount = selectedAmount {
                question += " \(amount.reconstructedEntity)"
            }
            else {
                question += " some money"
            }
            
            if selectedRecipientUnsure, let recipient = selectedRecipient {
                question += " to \(recipient.reconstructedEntity)"
            }
            
            if selectedBankAccountUnsure, let bankAccount = selectedBankAccount {
                question += " using your \(bankAccount.reconstructedEntity) account"
            }
            
            question += "?"
            
            let response: VocalAssistantResponse = .justAnswer(
                answer: "Just to confirm,",
                followUpQuestion: question
            )
            
            // create and return the 'unsure' state
            let unsureState = UnsureSendMoneyDstState(
                lastResponse: response,
                previousState: previousState,
                possibleAmount: selectedAmount,
                possibleRecipient: selectedRecipient,
                possibleBankAccount: selectedBankAccount,
                appContext: appContext
            )
            
            return (unsureState, response)
        }
        
        // * every specified info is 'sure' here (and it is one at most) *
        // now look for matching entities
        
        
        
        
        // TODO: implement method
        return (state: nil, .appError(errorMessage: "todo", answer: "todo", followUpQuestion: "todo"))
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
