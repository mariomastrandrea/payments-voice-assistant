//
//  WaitAmountRequestMoneyDstState.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 04/02/24.
//

import Foundation

class WaitAmountRequestMoneyDstState: RequestMoneyDstState {
    override var description: String {
        return "WaitAmountRequestMoneyDstState(amount: \(self.amount?.description ?? "nil"), sender: \(self.sender?.description ?? "nil"), bankAccount: \(self.bankAccount?.description ?? "nil"))"
    }
    
    // (inherit the same initializer)
    
    override func userExpressedNoneIntent(entities: [PaymentsEntity], stateChanger: DstStateChanger) -> VocalAssistantResponse {
        // look for amount entities
        let amountEntities = entities.filter { $0.type == .amount }
        
        // check if more entities than needed have been specified
        let numConfidentAmounts = amountEntities.filter { $0.entityProbability >= Self.threshold }.count
        
        if numConfidentAmounts > 1 {
            // more than one amount has been specified by the user
            let exceedingEntitiesErrorMsg = "Please specify just one amount to request some money."
            
            // do not create a new state, instead repeat the same question
            let response: VocalAssistantResponse = .justAnswer(
                answer: exceedingEntitiesErrorMsg,
                followUpQuestion: self.lastResponse.followUpQuestion
            )
            
            self.lastResponse = response
            return response
        }
        
        // retrieve the needed entity (amount)
        // give prededence to the one with probability greater or equal than the threshold, if any
        
        var selectedAmount = amountEntities.first { $0.entityProbability >= Self.threshold }
        var selectedAmountUnsure = false
        
        if selectedAmount == nil {
            // select the first with entity probability < threhsold (if any)
            selectedAmount = amountEntities.first
            if selectedAmount != nil {
                selectedAmountUnsure = true
            }
        }
        
        // check if the entity probability is below the threshold
        if selectedAmountUnsure {
            // amount is not sure
            let response: VocalAssistantResponse = .justAnswer(
                answer: "Just to confirm,",
                followUpQuestion: "do you want to request \(selectedAmount!.reconstructedEntity)?"
            )
            
            // create and go to the 'unsure' state, keeping the old entities, if any
            let unsureState = UnsureRequestMoneyDstState(
                lastResponse: response,
                previousState: self,
                possibleAmount: selectedAmount,
                // (keep the old selected entities)
                possibleSender: self.sender?.toEntity(),
                possibleBankAccount: self.bankAccount?.toEntity(),
                appContext: self.appContext
            )
            
            stateChanger.changeDstState(to: unsureState)
            return response
        }
        
        // * every specified info is 'sure' here (and it is one at most) *
        // now look for matching entities
        
        var matchingAmount: VocalAssistantAmount?
        
        if let possibleAmount = selectedAmount {
            // an amount has been specified -> parse amount
            let possibleUniqueCurrencies = Array(Set(self.appContext.userBankAccounts.map { $0.currency }))
            
            matchingAmount = VocalAssistantAmount(
                fromEntity: possibleAmount.reconstructedEntity,
                possibleCurrencies: possibleUniqueCurrencies
            )
        }
        
        guard let matchingAmount = matchingAmount else {
            // no correct amount has been specified here -> maintain the state and repeat the question
            let response: VocalAssistantResponse = .justAnswer(
                answer: "Sorry, I didn't quite understand how much you want to request (please specify the amount together with the correct currency).",
                followUpQuestion: self.lastResponse.followUpQuestion
            )
            
            self.lastResponse = response
            return response
        }
        
        // * amount correctly specified by the user *
        
        // if the bank account was already specified...
        if let alreadySpecifiedBankAccount = self.bankAccount {
            // check that the specified amount currency is coherent with the bank account
            if alreadySpecifiedBankAccount.currency != matchingAmount.currency {
                // currencies are not coherent
                let response: VocalAssistantResponse = .justAnswer(
                    answer: "Ok, but the mentioned amount is in \(matchingAmount.currency.literalPlural) and your \(alreadySpecifiedBankAccount.name) account is in \(alreadySpecifiedBankAccount.currency.literalPlural). Please specify an amount with a coherent currency.",
                    followUpQuestion: "How much do you want to request?"
                )
                
                self.lastResponse = response
                return response
            }
        }
        
        // check for any old sender
        guard let alreadySpecifiedSender = self.sender else {
            // go to Wait Sender Request Money state and save the matching amount
            
            let response: VocalAssistantResponse = .justAnswer(
                answer: "Ok.",
                followUpQuestion: "Who do you want to request this money from?"
            )
            
            let newState = WaitSenderRequestMoneyDstState(
                firstResponse: response,
                appContext: self.appContext,
                amount: matchingAmount,
                sender: nil,
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
                amount: matchingAmount,
                sender: alreadySpecifiedSender,
                bankAccount: nil
            )
            
            stateChanger.changeDstState(to: newState)
            return response
        }
        
        // * all the three entities have been specified -> go to confirmation stage *
        
        let response: VocalAssistantResponse = .requestMoneyConfirmationQuestion(
            answer: "Got it.",
            amount: matchingAmount,
            sender: alreadySpecifiedSender,
            destinationBankAccount: alreadySpecifiedBankAccount
        )
        
        let newConfirmationState = ConfirmationRequestMoneyDstState(
            lastResponse: response,
            amountToConfirm: matchingAmount,
            senderToConfirm: alreadySpecifiedSender,
            destinationBankAccountToConfirm: alreadySpecifiedBankAccount,
            appContext: self.appContext
        )
        
        stateChanger.changeDstState(to: newConfirmationState)
        return response
    }
}
