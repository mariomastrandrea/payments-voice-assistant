//
//  WaitBankAccountSendMoneyDstState.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 04/02/24.
//

import Foundation

class WaitBankAccountSendMoneyDstState: SendMoneyDstState {
    override var description: String {
        return "WaitBankAccountSendMoneyDstState(amount: \(self.amount?.description ?? "nil"), receiver: \(self.recipient?.description ?? "nil"), bankAccount: \(self.bankAccount?.description ?? "nil"))"
    }
    
    // (inherit the same initializer)
    
    override func userExpressedNoneIntent(entities: [PaymentsEntity], stateChanger: DstStateChanger) -> VocalAssistantResponse {
        // look for bank entities
        let bankEntities = entities.filter { $0.type == .bank }
        
        // check if more entities than needed have been specified
        let numConfidentBanks = bankEntities.filter { $0.entityProbability >= Self.threshold }.count
        
        if numConfidentBanks > 1 {
            // more than one bank has been specified by the user
            let exceedingEntitiesErrorMsg = "Please specify just one bank account to send the money."
            
            // do not create a new state, instead repeat the same question
            let response: VocalAssistantResponse = .justAnswer(
                answer: exceedingEntitiesErrorMsg,
                followUpQuestion: self.lastResponse.followUpQuestion
            )
            
            self.lastResponse = response
            return response
        }
        
        // retrieve the needed entity (bank)
        // give prededence to the one with probability greater or equal than the threshold, if any
        
        var selectedBankAccount = bankEntities.first { $0.entityProbability >= Self.threshold }
        var selectedBankAccountUnsure = false
        
        if selectedBankAccount == nil {
            // select the first with entity probability < threhsold (if any)
            selectedBankAccount = bankEntities.first
            if selectedBankAccount != nil {
                selectedBankAccountUnsure = true
            }
        }
        
        // check if the entity probability is below the threshold
        if selectedBankAccountUnsure {
            // bank entity is not sure
            let response: VocalAssistantResponse = .justAnswer(
                answer: "Just to confirm,",
                followUpQuestion: "are you requesting to send the money using your \(selectedBankAccount!.reconstructedEntity) account?"
            )
            
            // create and go to the 'unsure' state, keeping the old entities, if any
            let unsureState = UnsureSendMoneyDstState(
                lastResponse: response,
                previousState: self,
                // (keep the old selected entities)
                possibleAmount: self.amount?.toEntity(),
                possibleRecipient: self.recipient?.toEntity(),
                possibleBankAccount: selectedBankAccount,
                appContext: self.appContext
            )
            
            stateChanger.changeDstState(to: unsureState)
            return response
        }
        
        // * every specified info is 'sure' here (and it is one at most) *
        // now look for matching entities
        
        var matchingBankAccounts = [VocalAssistantBankAccount]()
        
        if let possibleBankAccount = selectedBankAccount {
            // a bank account has been mentioned -> look for matching bank accounts
            matchingBankAccounts = self.appContext.userBankAccounts.filter { bankAccount in
                bankAccount.match(with: possibleBankAccount.reconstructedEntity)
            }
        }
        
        guard matchingBankAccounts.isNotEmpty else {
            // no matching bank accounts has been found -> maintain the state and repeat the question
            let response: VocalAssistantResponse = .justAnswer(
                answer: "Sorry, I didn't find any bank account matching your request.",
                followUpQuestion: self.lastResponse.followUpQuestion
            )
            
            self.lastResponse = response
            return response
        }
        
        if matchingBankAccounts.areMoreThanOne {
            // ask the user to choose one and maintain the state
            let response: VocalAssistantResponse = .chooseBankAccount(among: matchingBankAccounts)
            
            self.lastResponse = response
            return response
        }
        
        // * (1) bank account correctly specified by the user *
        let matchingBankAccount = matchingBankAccounts[0]
        
        // check for any old amount
        guard let alreadySpecifiedAmount = self.amount else {
            // go to Wait Amount Send Money state and save the matching bank account and any eventual old recipient
            
            let response: VocalAssistantResponse = .justAnswer(
                answer: "Ok.",
                followUpQuestion: "How much do you want to send?"
            )
            
            let newState = WaitAmountSendMoneyDstState(
                firstResponse: response,
                appContext: self.appContext,
                amount: nil,
                recipient: self.recipient,
                bankAccount: matchingBankAccount
            )
            
            stateChanger.changeDstState(to: newState)
            return response
        }
        
        // check for any old recipient
        guard let alreadySpecifiedRecipient = self.recipient else {
            // go to Wait Recipient Send Money state and save the matching bank account
            
            let response: VocalAssistantResponse = .justAnswer(
                answer: "Ok.",
                followUpQuestion: "Who do you want to send the money to?"
            )
            
            let newState = WaitBankAccountSendMoneyDstState(
                firstResponse: response,
                appContext: self.appContext,
                amount: alreadySpecifiedAmount,
                recipient: nil,
                bankAccount: matchingBankAccount
            )
            
            stateChanger.changeDstState(to: newState)
            return response
        }
        
        // * all the three entities have been specified -> go to confirmation stage *
        
        let response: VocalAssistantResponse = .sendMoneyConfirmationQuestion(
            answer: "Got it.",
            amount: alreadySpecifiedAmount,
            recipient: alreadySpecifiedRecipient,
            sourceBankAccount: matchingBankAccount
        )
        
        let newConfirmationState = ConfirmationSendMoneyDstState(
            lastResponse: response,
            amountToConfirm: alreadySpecifiedAmount,
            recipientToConfirm: alreadySpecifiedRecipient,
            sourceBankAccountToConfirm: matchingBankAccount,
            appContext: self.appContext
        )
        
        stateChanger.changeDstState(to: newConfirmationState)
        return response
    }
}
