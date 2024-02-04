//
//  WaitRecipientSendMoneyDstState.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 04/02/24.
//

import Foundation

class WaitRecipientSendMoneyDstState: SendMoneyDstState {
    override var description: String {
        return "WaitRecipientSendMoneyDstState(amount: \(self.amount?.description ?? "nil"), receiver: \(self.recipient?.description ?? "nil"), bankAccount: \(self.bankAccount?.description ?? "nil"))"
    }
    
    // (inherit the same initializer)
    
    override func userExpressedNoneIntent(entities: [PaymentsEntity], stateChanger: DstStateChanger) -> VocalAssistantResponse {
        // look for user entities
        let userEntities = entities.filter { $0.type == .user }
        
        // check if more entities than needed have been specified
        let numConfidentUsers = userEntities.filter { $0.entityProbability >= Self.threshold }.count
        
        if numConfidentUsers > 1 {
            // more than one contact has been specified by the user
            let exceedingEntitiesErrorMsg = "Please specify just one contact to send the money to."
            
            // do not create a new state, instead repeat the same question
            let response: VocalAssistantResponse = .justAnswer(
                answer: exceedingEntitiesErrorMsg,
                followUpQuestion: self.lastResponse.followUpQuestion
            )
            
            self.lastResponse = response
            return response
        }
        
        // retrieve the needed entity (user)
        // give prededence to the one with probability greater or equal than the threshold, if any
        
        var selectedContact = userEntities.first { $0.entityProbability >= Self.threshold }
        var selectedContactUnsure = false
        
        if selectedContact == nil {
            // select the first with entity probability < threhsold (if any)
            selectedContact = userEntities.first
            if selectedContact != nil {
                selectedContactUnsure = true
            }
        }
        
        // check if the entity probability is below the threshold
        if selectedContactUnsure {
            // contact entity is not sure
            let response: VocalAssistantResponse = .justAnswer(
                answer: "Just to confirm,",
                followUpQuestion: "are you requesting to send the money to \(selectedContact!.reconstructedEntity)?"
            )
            
            // create and go to the 'unsure' state, keeping the old entities, if any
            let unsureState = UnsureSendMoneyDstState(
                lastResponse: response,
                previousState: self,
                // (keep the old selected entities)
                possibleAmount: self.amount?.toEntity(),
                possibleRecipient: selectedContact,
                possibleBankAccount: self.bankAccount?.toEntity(),
                appContext: self.appContext
            )
            
            stateChanger.changeDstState(to: unsureState)
            return response
        }
        
        // * every specified info is 'sure' here (and it is one at most) *
        // now look for matching entities
        
        var matchingRecipients = [VocalAssistantContact]()
        
        if let possibleRecipient = selectedContact {
            // a recipient has been mentioned -> look for matching contacts
            matchingRecipients = self.appContext.userContacts.keepAndOrderJustTheOnesSimilar(to: possibleRecipient.reconstructedEntity)
        }
        
        guard matchingRecipients.isNotEmpty else {
            // no matching contact has been found -> maintain the state and repeat the question
            let response: VocalAssistantResponse = .justAnswer(
                answer: "Sorry, I didn't find any contact matching your request.",
                followUpQuestion: self.lastResponse.followUpQuestion
            )
            
            self.lastResponse = response
            return response
        }
        
        if matchingRecipients.areMoreThanOne {
            // ask the user to choose one
            let response: VocalAssistantResponse = .chooseContact(among: matchingRecipients)
            
            self.lastResponse = response
            return response
        }
        
        // * (1) recipient correctly specified by the user *
        let matchingRecipient = matchingRecipients[0]
        
        // check for any old amount
        guard let alreadySpecifiedAmount = self.amount else {
            // go to Wait Amount Send Money state and save the matching recipient and any eventual old account
            
            let response: VocalAssistantResponse = .justAnswer(
                answer: "Ok.",
                followUpQuestion: "How much do you want to send?"
            )
            
            let newState = WaitAmountSendMoneyDstState(
                firstResponse: response,
                appContext: self.appContext,
                amount: nil,
                recipient: matchingRecipient,
                bankAccount: self.bankAccount
            )
            
            stateChanger.changeDstState(to: newState)
            return response
        }
        
        // check for any old bank account
        guard let alreadySpecifiedBankAccount = self.bankAccount else {
            // go to Wait Bank Account Send Money state and save the matching amount
            
            let response: VocalAssistantResponse = .justAnswer(
                answer: "Ok.",
                followUpQuestion: "Which of your bank accounts do you want to use?\nYour bank accounts are at: \(self.appContext.userBankAccounts.map{$0.description}.joinGrammatically())"
            )
            
            let newState = WaitBankAccountSendMoneyDstState(
                firstResponse: response,
                appContext: self.appContext,
                amount: alreadySpecifiedAmount,
                recipient: matchingRecipient,
                bankAccount: nil
            )
            
            stateChanger.changeDstState(to: newState)
            return response
        }
        
        // * all the three entities have been specified -> go to confirmation stage *
        
        let response: VocalAssistantResponse = .sendMoneyConfirmationQuestion(
            answer: "Got it.",
            amount: alreadySpecifiedAmount,
            recipient: matchingRecipient,
            sourceBankAccount: alreadySpecifiedBankAccount
        )
        
        let newConfirmationState = ConfirmationSendMoneyDstState(
            lastResponse: response,
            amountToConfirm: alreadySpecifiedAmount,
            recipientToConfirm: matchingRecipient,
            sourceBankAccountToConfirm: alreadySpecifiedBankAccount,
            appContext: self.appContext
        )
        
        stateChanger.changeDstState(to: newConfirmationState)
        return response
    }
}
