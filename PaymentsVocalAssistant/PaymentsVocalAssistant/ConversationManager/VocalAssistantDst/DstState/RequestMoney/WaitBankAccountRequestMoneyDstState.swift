//
//  WaitBankAccountRequestMoneyDstState.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 04/02/24.
//

import Foundation

class WaitBankAccountRequestMoneyDstState: RequestMoneyDstState {
    override var description: String {
        return "WaitBankAccountRequestMoneyDstState(amount: \(self.amount?.description ?? "nil"), sender: \(self.sender?.description ?? "nil"), bankAccount: \(self.bankAccount?.description ?? "nil"))"
    }
    
    // (inherit the same initializer)
    
    override func userExpressedNoneIntent(entities: [PaymentsEntity], stateChanger: DstStateChanger) -> VocalAssistantResponse {
        // look for bank entities
        let bankEntities = entities.filter { $0.type == .bank }
        
        // check if more entities than needed have been specified
        let numConfidentBanks = bankEntities.filter { $0.entityProbability >= Self.threshold }.count
        
        if numConfidentBanks > 1 {
            // more than one bank has been specified by the user
            let exceedingEntitiesErrorMsg = "Please specify just one bank account to request the money."
            
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
                followUpQuestion: "do you want to request the money using your \(selectedBankAccount!.reconstructedEntity) account?"
            )
            
            // create and go to the 'unsure' state, keeping the old entities, if any
            let unsureState = UnsureRequestMoneyDstState(
                lastResponse: response,
                previousState: self,
                // (keep the old selected entities)
                possibleAmount: self.amount?.toEntity(),
                possibleSender: self.sender?.toEntity(),
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
            // maintain the state and ask the user to choose one
            let response: VocalAssistantResponse = .chooseBankAccount(among: matchingBankAccounts)
            
            self.lastResponse = response
            return response
        }
        
        // * (1) bank account correctly specified by the user *
        let matchingBankAccount = matchingBankAccounts[0]
        
        // check for any old amount
        guard let alreadySpecifiedAmount = self.amount else {
            // go to Wait Amount Request Money state and save the matching bank account and any eventual old sender
            
            let response: VocalAssistantResponse = .justAnswer(
                answer: "Ok.",
                followUpQuestion: "How much do you want to request?"
            )
            
            let newState = WaitAmountRequestMoneyDstState(
                firstResponse: response,
                appContext: self.appContext,
                amount: nil,
                sender: self.sender,
                bankAccount: matchingBankAccount
            )
            
            stateChanger.changeDstState(to: newState)
            return response
        }
        
        // check for any old sender
        guard let alreadySpecifiedSender = self.sender else {
            // go to Wait Sender Request Money state and save the matching bank account
            
            let response: VocalAssistantResponse = .justAnswer(
                answer: "Ok.",
                followUpQuestion: "Who do you want to request the money from?"
            )
            
            let newState = WaitBankAccountRequestMoneyDstState(
                firstResponse: response,
                appContext: self.appContext,
                amount: alreadySpecifiedAmount,
                sender: nil,
                bankAccount: matchingBankAccount
            )
            
            stateChanger.changeDstState(to: newState)
            return response
        }
        
        // * all the three entities have been specified -> go to confirmation stage *
        
        let response: VocalAssistantResponse = .requestMoneyConfirmationQuestion(
            answer: "Got it.",
            amount: alreadySpecifiedAmount,
            sender: alreadySpecifiedSender,
            destinationBankAccount: matchingBankAccount
        )
        
        let newConfirmationState = ConfirmationRequestMoneyDstState(
            lastResponse: response,
            amountToConfirm: alreadySpecifiedAmount,
            senderToConfirm: alreadySpecifiedSender,
            destinationBankAccountToConfirm: matchingBankAccount,
            appContext: self.appContext
        )
        
        stateChanger.changeDstState(to: newConfirmationState)
        return response
    }
}
