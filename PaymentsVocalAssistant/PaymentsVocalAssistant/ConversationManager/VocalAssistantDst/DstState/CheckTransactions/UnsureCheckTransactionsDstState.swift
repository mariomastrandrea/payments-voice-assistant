//
//  UnsureCheckTransactionsDstState.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 02/02/24.
//

import Foundation

class UnsureCheckTransactionsDstState: CheckTransactionsDstState {
    override var description: String {
        return "UnsureCheckTransactionsDstState()"
    }
    
    private var previousState: DstState
    private var possibleBankAccount: PaymentsEntity?
    private var possibleContact: PaymentsEntity?
    
    init(lastResponse: VocalAssistantResponse, previousState: DstState, possibleBankAccount: PaymentsEntity? = nil, possibleContact: PaymentsEntity? = nil, appContext: AppContext) {
        self.previousState = previousState
        self.possibleBankAccount = possibleBankAccount
        self.possibleContact = possibleContact
        
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
        // either the intent is unsure or one (or more) entities are unsure
        
        var matchingBankAccounts: [VocalAssistantBankAccount] = []
        var matchingContacts: [VocalAssistantContact] = []
        
        if let possibleBankAccount = self.possibleBankAccount {
            // the bank account was unsure
            matchingBankAccounts = self.appContext.userBankAccounts.filter { bankAccount in
                bankAccount.match(with: possibleBankAccount.reconstructedEntity)
            }
        }
        
        if let possibleContact = self.possibleContact {
            // the contact was unsure
            matchingContacts = self.appContext.userContacts.keepAndOrderJustTheOnesSimilar(to: possibleContact.reconstructedEntity)
        }
        
        // (priority to the contacts)
        
        if matchingContacts.count > 1 {
            // more than one contact matched -> change state and ask to choose one
            let response: VocalAssistantResponse = .chooseContact(among: matchingContacts)
            
            // save the bank account only if just one matches
            let eventualMatchingBankAccount = matchingBankAccounts.count == 1 ? matchingBankAccounts[0] : nil
            
            let newState = CheckTransactionsDstState(firstResponse: response, appContext: self.appContext, bankAccount: eventualMatchingBankAccount)
            stateChanger.changeDstState(to: newState)
            
            return response
        }
        
        if matchingBankAccounts.count > 1 {
            // more than one bank account matched -> change state and ask to choose one
            let response: VocalAssistantResponse = .chooseBankAccount(among: matchingBankAccounts)
            
            // save the contact only if just one matches
            let eventualMatchingContact = matchingContacts.count == 1 ? matchingContacts[0] : nil
            
            let newState = CheckTransactionsDstState(firstResponse: response, appContext: self.appContext, contact: eventualMatchingContact)
            stateChanger.changeDstState(to: newState)
            
            return response
        }
        
        var matchingNotFoundMessages = [String]()
        
        if possibleContact != nil && matchingContacts.isEmpty {
            matchingNotFoundMessages.append("I didn't find any contact matching your request")
        }
        
        if possibleBankAccount != nil && matchingBankAccounts.isEmpty {
            matchingNotFoundMessages.append("I didn't find any bank account matching your request")
        }
        
        var matchingNotFoundMessage = matchingNotFoundMessages.joined(separator: " and ")
        if matchingNotFoundMessage.isNotEmpty { matchingNotFoundMessage += "." }
        
        let eventualMatchingBankAccount = matchingBankAccounts[safe: 0]
        let eventualMatchingContact = matchingContacts[safe: 0]
        
        // create check transaction operation response + change to 'sure' state
        let response: VocalAssistantResponse = .checkTransactionsOperation(
            bankAccount: eventualMatchingBankAccount,
            contact: eventualMatchingContact,
            preAnswer: matchingNotFoundMessage
        )
        
        let newState = CheckTransactionsDstState(
            firstResponse: response,
            appContext: self.appContext,
            bankAccount: eventualMatchingBankAccount,
            contact: eventualMatchingContact
        )
        
        stateChanger.changeDstState(to: newState)
        
        return response
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
