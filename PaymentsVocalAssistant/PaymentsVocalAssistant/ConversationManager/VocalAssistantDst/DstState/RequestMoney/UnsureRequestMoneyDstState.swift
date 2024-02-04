//
//  UnsureRequestMoneyDstState.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 04/02/24.
//

import Foundation

class UnsureRequestMoneyDstState: RequestMoneyDstState {
    override var description: String {
        return "UnsureRequestMoneyDstState(possibleAmount: \(self.possibleAmount?.reconstructedEntity ?? "nil"), possibleSender: \(self.possibleSender?.reconstructedEntity ?? "nil"), possibleBankAccount: \(self.possibleBankAccount?.reconstructedEntity ?? "nil"))"
    }
    
    private var previousState: DstState
    private var possibleAmount: PaymentsEntity?
    private var possibleSender: PaymentsEntity?
    private var possibleBankAccount: PaymentsEntity?
    
    init(lastResponse: VocalAssistantResponse, previousState: DstState, possibleAmount: PaymentsEntity?, possibleSender: PaymentsEntity?, possibleBankAccount: PaymentsEntity?, appContext: AppContext) {
        self.previousState = previousState
        self.possibleAmount = possibleAmount
        self.possibleSender = possibleSender
        self.possibleBankAccount = possibleBankAccount
        
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
        // look for entity matches
        
        var matchingAmount: VocalAssistantAmount?
        var matchingSenders = [VocalAssistantContact]()
        var matchingBankAccounts = [VocalAssistantBankAccount]()
        
        if let possibleAmount = self.possibleAmount {
            // an amount has been specified -> parse amount
            let possibleUniqueCurrencies = Array(Set(self.appContext.userBankAccounts.map { $0.currency }))
            
            matchingAmount = VocalAssistantAmount(
                fromEntity: possibleAmount.reconstructedEntity,
                possibleCurrencies: possibleUniqueCurrencies
            )
        }
        
        if let possibleSender = self.possibleSender {
            // a sender has been mentioned -> look for matching contacts
            matchingSenders = self.appContext.userContacts.keepAndOrderJustTheOnesSimilar(to: possibleSender.reconstructedEntity)
        }
        
        if let possibleBankAccount = self.possibleBankAccount {
            // a bank account has been mentioned -> look for matching bank account
            matchingBankAccounts = self.appContext.userBankAccounts.filter { bankAccount in
                bankAccount.match(with: possibleBankAccount.reconstructedEntity)
            }
        }
        else { // user did not mention any bank account, but if they have just one bank account, use it by default
            if self.appContext.userBankAccounts.count == 1 {
                matchingBankAccounts.append(self.appContext.userBankAccounts[0])
            }
        }
        
        // look for wrong matchings (misunderstandings)
        
        var matchingNotFoundMessages = [String]()
                
        if self.possibleAmount != nil && matchingAmount == nil {
            // amount has not been understood
            matchingNotFoundMessages.append("I didn't quite understand how much you want to request (please specify the amount together with the correct currency)")
        }
        
        if self.possibleSender != nil && matchingSenders.isEmpty {
            // sender has not been understood
            matchingNotFoundMessages.append("I didn't find any contact matching your request")
        }
        
        if self.possibleBankAccount != nil && matchingBankAccounts.isEmpty {
            // bank account has not been understood
            matchingNotFoundMessages.append("I didn't find any bank account matching your request")
        }
        
        var matchingNotFoundMessage = matchingNotFoundMessages.joinGrammatically()
        if matchingNotFoundMessage.isNotEmpty {
            matchingNotFoundMessage = "Ok, but " + matchingNotFoundMessage + "."
        }
        
        // * priority to: amount -> sender -> bank account *
        
        guard let matchingAmount = matchingAmount else {
            // ask to specify the amount and go to the 'sure' state, saving any relevant state info
            
            let response: VocalAssistantResponse = .justAnswer(
                answer: matchingNotFoundMessage.isEmpty ? "Ok." : matchingNotFoundMessage,
                followUpQuestion: "How much do you want to request?"
            )
            
            // save sender and bank account only if there is just one match
            let eventualMatchingSender = matchingSenders.count == 1 ? matchingSenders[0] : nil
            let eventualMatchingBankAccount = matchingBankAccounts.count == 1 ? matchingBankAccounts[0] : nil
            
            let newSureState = WaitAmountRequestMoneyDstState(
                firstResponse: response,
                appContext: self.appContext,
                amount: nil,
                sender: eventualMatchingSender,
                bankAccount: eventualMatchingBankAccount
            )
            stateChanger.changeDstState(to: newSureState)
            
            return response
        }
        
        // (here amount is specified)
        
        if matchingSenders.isEmpty {
            // ask to specify the sender and go to the 'sure' state, saving any relevant state info
            
            let eventualMatchingBankAccount = matchingBankAccounts.count == 1 ? matchingBankAccounts[0] : nil
            
            // check first if bank account is coherent with the specified currency
            if let bankAccount = eventualMatchingBankAccount,
             bankAccount.currency != matchingAmount.currency {
                // the specified bank account is not in the same currency as the specified amount
                
                matchingNotFoundMessage = "Ok, but your \(bankAccount.name) account is not in \(matchingAmount.currency.literalPlural). Please specify an amount with a coherent currency."
                
                let response: VocalAssistantResponse = .justAnswer(
                    answer: matchingNotFoundMessage,
                    followUpQuestion: "How much do you want to request?"
                )
                
                let newSureState = WaitAmountRequestMoneyDstState(
                    firstResponse: response,
                    appContext: self.appContext,
                    amount: nil,
                    sender: nil,
                    bankAccount: bankAccount
                )
                stateChanger.changeDstState(to: newSureState)
                return response
            }
            
            let response: VocalAssistantResponse = .justAnswer(
                answer: matchingNotFoundMessage.isEmpty ? "Ok." : matchingNotFoundMessage,
                followUpQuestion: "Who do you want to request this money from?"
            )
            
            let newSureState = WaitSenderRequestMoneyDstState(
                firstResponse: response,
                appContext: self.appContext,
                amount: matchingAmount,
                sender: nil,
                bankAccount: eventualMatchingBankAccount
            )
            
            stateChanger.changeDstState(to: newSureState)
            return response
        }
        
        // (here amount is specified and there are >= 1 specified senders)
        
        if matchingBankAccounts.isEmpty {
            // ask to specify the bank account and go to the 'sure' state, saving any relevant state info
            
            // save the sender only if it has been perfectly matched with only one contact
            let eventualMatchingSender = matchingSenders.count == 1 ? matchingSenders[0] : nil
            
            let response: VocalAssistantResponse = .justAnswer(
                answer: matchingNotFoundMessage.isEmpty ? "Ok." : matchingNotFoundMessage,
                followUpQuestion: "Which of your bank accounts do you want to use?\nYour bank accounts are at: \(self.appContext.userBankAccounts.map{$0.description}.joinGrammatically())"
            )
            
            let newSureState = WaitBankAccountRequestMoneyDstState(
                firstResponse: response,
                appContext: self.appContext,
                amount: matchingAmount,
                sender: eventualMatchingSender,
                bankAccount: nil
            )
            
            stateChanger.changeDstState(to: newSureState)
            return response
        }
        
        // here every info is specified, but sender and bank account might have more than one match
        // (precedence to sender)
        
        if matchingSenders.areMoreThanOne {
            // ask to choose among matching contacts, and go to the 'sure' state, saving any relevant state info, and eventually checking that the currency is coherent with the bank account
            
            let eventualMatchingBankAccount = matchingBankAccounts.count == 1 ? matchingBankAccounts[0] : nil
            
            if let bankAccount = eventualMatchingBankAccount,
               bankAccount.currency != matchingAmount.currency {
                // the specified bank account is not in the same currency as the specified amount -> ask to specify a correct amount
                                
                matchingNotFoundMessage = "Ok, but your \(bankAccount.name) account is not in \(matchingAmount.currency.literalPlural). Please specify an amount with a coherent currency."
                
                let response: VocalAssistantResponse = .justAnswer(
                    answer: matchingNotFoundMessage,
                    followUpQuestion: "How much do you want to request?"
                )
                
                let newSureState = WaitAmountRequestMoneyDstState(
                    firstResponse: response,
                    appContext: self.appContext,
                    amount: nil,
                    sender: nil,
                    bankAccount: bankAccount
                )
                stateChanger.changeDstState(to: newSureState)
                return response
            }
            
            let response: VocalAssistantResponse = .askToChooseContact(
                contacts: matchingSenders,
                answer: "Ok, I've found multiple contacts matching your request.",
                followUpQuestion: "Who do you want to request this money from?"
            )
            
            let newSureState = WaitSenderRequestMoneyDstState(
                firstResponse: response,
                appContext: self.appContext,
                amount: matchingAmount,
                sender: nil,
                bankAccount: eventualMatchingBankAccount
            )
            
            stateChanger.changeDstState(to: newSureState)
            return response
        }
        
        let matchingSender = matchingSenders[0]
        // here both amount and sender have been specified, but the matching bank accounts might be more than one
        
        // check that the matching bank accounts have all the same currency as the specified one
        matchingBankAccounts = matchingBankAccounts.filter { $0.currency == matchingAmount.currency }
        
        guard matchingBankAccounts.isNotEmpty else {
            // all the matching accounts have a different currency than the one mentioned by the user
            
            let response: VocalAssistantResponse = .askToChooseBankAccount(
                bankAccounts: self.appContext.userBankAccounts.filter { $0.currency == matchingAmount.currency },
                answer: "Ok, but the mentioned bank account is not in \(matchingAmount.currency.literalPlural). Please specify a bank account with a coherent currency.",
                followUpQuestion: "Which of your bank accounts do you want to use to request that money?"
            )
            
            let newSureState = WaitBankAccountRequestMoneyDstState(
                firstResponse: response,
                appContext: self.appContext,
                amount: matchingAmount,
                sender: matchingSender,
                bankAccount: nil
            )
            
            stateChanger.changeDstState(to: newSureState)
            return response
        }
        
        if matchingBankAccounts.areMoreThanOne {
            // ask to choose among matching bank accounts, and go to the 'sure' state, saving the relevant info
            
            let response: VocalAssistantResponse = .askToChooseBankAccount(
                bankAccounts: matchingBankAccounts,
                answer: "Ok, I've found multiple bank accounts matching your request.",
                followUpQuestion: "Which one do you want to use?"
            )
            
            let newSureState = WaitBankAccountRequestMoneyDstState(
                firstResponse: response,
                appContext: self.appContext,
                amount: matchingAmount,
                sender: matchingSender,
                bankAccount: nil
            )
            
            stateChanger.changeDstState(to: newSureState)
            return response
        }
        
        let matchingBankAccount = matchingBankAccounts[0]

        // * here the amount is specified, with only one sender, and only one (coherent) bank account *
        // go to the confirmation stage
        
        let response: VocalAssistantResponse = .requestMoneyConfirmationQuestion(
            answer: "Ok.",
            amount: matchingAmount,
            sender: matchingSender,
            destinationBankAccount: matchingBankAccount
        )
        
        let newConfirmationState = ConfirmationRequestMoneyDstState(
            lastResponse: response,
            amountToConfirm: matchingAmount,
            senderToConfirm: matchingSender,
            destinationBankAccountToConfirm: matchingBankAccount,
            appContext: self.appContext
        )
        
        stateChanger.changeDstState(to: newConfirmationState)
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
