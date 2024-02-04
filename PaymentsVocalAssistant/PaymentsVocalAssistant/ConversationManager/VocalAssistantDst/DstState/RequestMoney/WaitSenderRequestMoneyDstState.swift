//
//  WaitSenderRequestMoneyDstState.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 04/02/24.
//

import Foundation

class WaitSenderRequestMoneyDstState: RequestMoneyDstState {
    override var description: String {
        return "WaitSenderRequestMoneyDstState(amount: \(self.amount?.description ?? "nil"), sender: \(self.sender?.description ?? "nil"), bankAccount: \(self.bankAccount?.description ?? "nil"))"
    }
    
    // (inherit the same initializer)
    
    override func userExpressedNoneIntent(entities: [PaymentsEntity], stateChanger: DstStateChanger) -> VocalAssistantResponse {
        // look for user entities
        let userEntities = entities.filter { $0.type == .user }
        
        // check if more entities than needed have been specified
        let numConfidentUsers = userEntities.filter { $0.entityProbability >= Self.threshold }.count
        
        if numConfidentUsers > 1 {
            // more than one contact has been specified by the user
            let exceedingEntitiesErrorMsg = "Please specify just one contact to request the money from."
            
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
                followUpQuestion: "do you want to request the money from \(selectedContact!.reconstructedEntity)?"
            )
            
            // create and go to the 'unsure' state, keeping the old entities, if any
            let unsureState = UnsureRequestMoneyDstState(
                lastResponse: response,
                previousState: self,
                // (keep the old selected entities)
                possibleAmount: self.amount?.toEntity(),
                possibleSender: selectedContact,
                possibleBankAccount: self.bankAccount?.toEntity(),
                appContext: self.appContext
            )
            
            stateChanger.changeDstState(to: unsureState)
            return response
        }
        
        // * every specified info is 'sure' here (and it is one at most) *
        // now look for matching entities
        
        var matchingSenders = [VocalAssistantContact]()
        
        if let possibleSender = selectedContact {
            // a sender has been mentioned -> look for matching contacts
            matchingSenders = self.appContext.userContacts.keepAndOrderJustTheOnesSimilar(to: possibleSender.reconstructedEntity)
        }
        
        guard matchingSenders.isNotEmpty else {
            // no matching contact has been found -> maintain the state and repeat the question
            let response: VocalAssistantResponse = .justAnswer(
                answer: "Sorry, I didn't find any contact matching your request.",
                followUpQuestion: self.lastResponse.followUpQuestion
            )
            
            self.lastResponse = response
            return response
        }
        
        if matchingSenders.areMoreThanOne {
            // ask the user to choose one
            let response: VocalAssistantResponse = .chooseContact(among: matchingSenders)
            
            self.lastResponse = response
            return response
        }
        
        // * (1) sender correctly specified by the user *
        let matchingSender = matchingSenders[0]
        
        // check for any old amount
        guard let alreadySpecifiedAmount = self.amount else {
            // go to Wait Amount Request Money state and save the matching sender and any eventual old account
            
            let response: VocalAssistantResponse = .justAnswer(
                answer: "Ok.",
                followUpQuestion: "How much do you want to request?"
            )
            
            let newState = WaitAmountRequestMoneyDstState(
                firstResponse: response,
                appContext: self.appContext,
                amount: nil,
                sender: matchingSender,
                bankAccount: self.bankAccount
            )
            
            stateChanger.changeDstState(to: newState)
            return response
        }
        
        // check for any old bank account
        guard let alreadySpecifiedBankAccount = self.bankAccount else {
            // go to Wait Bank Account Request Money state and save the matching amount
            
            let response: VocalAssistantResponse = .justAnswer(
                answer: "Ok.",
                followUpQuestion: "Which of your bank accounts do you want to use?\nYour bank accounts are at: \(self.appContext.userBankAccounts.map{$0.description}.joinGrammatically())"
            )
            
            let newState = WaitBankAccountRequestMoneyDstState(
                firstResponse: response,
                appContext: self.appContext,
                amount: alreadySpecifiedAmount,
                sender: matchingSender,
                bankAccount: nil
            )
            
            stateChanger.changeDstState(to: newState)
            return response
        }
        
        // * all the three entities have been specified -> go to confirmation stage *
        
        let response: VocalAssistantResponse = .requestMoneyConfirmationQuestion(
            answer: "Got it.",
            amount: alreadySpecifiedAmount,
            sender: matchingSender,
            destinationBankAccount: alreadySpecifiedBankAccount
        )
        
        let newConfirmationState = ConfirmationRequestMoneyDstState(
            lastResponse: response,
            amountToConfirm: alreadySpecifiedAmount,
            senderToConfirm: matchingSender,
            destinationBankAccountToConfirm: alreadySpecifiedBankAccount,
            appContext: self.appContext
        )
        
        stateChanger.changeDstState(to: newConfirmationState)
        return response
    }
}
