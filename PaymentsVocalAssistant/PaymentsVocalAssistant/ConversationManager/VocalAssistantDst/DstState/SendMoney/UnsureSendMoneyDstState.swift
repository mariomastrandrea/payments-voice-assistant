//
//  UnsureSendMoneyDstState.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 04/02/24.
//

import Foundation

class UnsureSendMoneyDstState: SendMoneyDstState {
    override var description: String {
        return "UnsureSendMoneyDstState(possibleAmount: \(self.possibleAmount?.reconstructedEntity ?? "nil"), possibleRecipient: \(self.possibleRecipient?.reconstructedEntity ?? "nil"), possibleBankAccount: \(self.possibleBankAccount?.reconstructedEntity ?? "nil"))"
    }
    
    private var previousState: DstState
    private var possibleAmount: PaymentsEntity?
    private var possibleRecipient: PaymentsEntity?
    private var possibleBankAccount: PaymentsEntity?
    
    init(lastResponse: VocalAssistantResponse, previousState: DstState, possibleAmount: PaymentsEntity?, possibleRecipient: PaymentsEntity?, possibleBankAccount: PaymentsEntity?, appContext: AppContext) {
        self.previousState = previousState
        self.possibleAmount = possibleAmount
        self.possibleRecipient = possibleRecipient
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
        var matchingRecipients = [VocalAssistantContact]()
        var matchingBankAccounts = [VocalAssistantBankAccount]()
        
        if let possibleAmount = self.possibleAmount {
            // amount was specified -> parse amount
            matchingAmount = VocalAssistantAmount(
                fromEntity: possibleAmount.reconstructedEntity,
                possibleCurrencies: Array(Set(self.appContext.userBankAccounts.map { $0.currency }))
            )
        }
        
        if let possibleRecipient = self.possibleRecipient {
            // a recipient has been mentioned -> look for matching contacts
            matchingRecipients = self.appContext.userContacts.keepAndOrderJustTheOnesSimilar(to: possibleRecipient.reconstructedEntity)
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
            matchingNotFoundMessages.append("I didn't quite understand how much you want to send (please specify the amount together with the correct currency)")
        }
        
        if self.possibleRecipient != nil && matchingRecipients.isEmpty {
            // recipient has not been understood
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
        
        // * priority to: amount -> recipient -> bank account *
        
        guard let matchingAmount = matchingAmount else {
            // ask to specify the amount and go to the 'sure' state, saving any relevant state info
            
            let response: VocalAssistantResponse = .justAnswer(
                answer: matchingNotFoundMessage.isEmpty ? "Ok." : matchingNotFoundMessage,
                followUpQuestion: "How much do you want to send?"
            )
            
            let eventualMatchingRecipient = matchingRecipients.count == 1 ? matchingRecipients[0] : nil
            let eventualMatchingBankAccount = matchingBankAccounts.count == 1 ? matchingBankAccounts[0] : nil
            
            let newSureState = SendMoneyDstState(
                firstResponse: response,
                appContext: self.appContext,
                amount: nil,
                recipient: eventualMatchingRecipient,
                bankAccount: eventualMatchingBankAccount
            )
            stateChanger.changeDstState(to: newSureState)
            
            return response
        }
        
        // (here amount is specified)
        
        if matchingRecipients.isEmpty {
            // ask to specify the recipient and go to the 'sure' state, saving any relevant state info
            
            let eventualMatchingBankAccount = matchingBankAccounts.count == 1 ? matchingBankAccounts[0] : nil
            
            // check first if bank account is coherent with the specified currency
            if let bankAccount = eventualMatchingBankAccount,
             bankAccount.currency != matchingAmount.currency {
                // the specified bank account is not in the same currency as the specified amount
                
                matchingNotFoundMessage = "Ok, but your \(bankAccount.name) account is not in \(matchingAmount.currency.literalPlural). Please specify an amount with a coherent currency."
                
                let response: VocalAssistantResponse = .justAnswer(
                    answer: matchingNotFoundMessage,
                    followUpQuestion: "How much do you want to send?"
                )
                
                let newSureState = SendMoneyDstState(
                    firstResponse: response,
                    appContext: self.appContext,
                    amount: nil,
                    recipient: nil,
                    bankAccount: bankAccount
                )
                stateChanger.changeDstState(to: newSureState)
                return response
            }
            
            let response: VocalAssistantResponse = .justAnswer(
                answer: matchingNotFoundMessage.isEmpty ? "Ok." : matchingNotFoundMessage,
                followUpQuestion: "Who do you want to send this money to?"
            )
            
            let newSureState = SendMoneyDstState(
                firstResponse: response,
                appContext: self.appContext,
                amount: matchingAmount,
                recipient: nil,
                bankAccount: eventualMatchingBankAccount
            )
            
            stateChanger.changeDstState(to: newSureState)
            return response
        }
        
        // (here amount is specified and there are >= 1 specified receivers)
        
        if matchingBankAccounts.isEmpty {
            // ask to specify the bank account and go to the 'sure' state, saving any relevant state info
            
            // save the recipient only if it has been perfectly matched with only one contact
            let eventualMatchingRecipient = matchingRecipients.count == 1 ? matchingRecipients[0] : nil
            
            let response: VocalAssistantResponse = .justAnswer(
                answer: matchingNotFoundMessage.isEmpty ? "Ok." : matchingNotFoundMessage,
                followUpQuestion: "Which of your bank accounts do you want to use?\nYour bank accounts are at: \(self.appContext.userBankAccounts.map{$0.description}.joinGrammatically())"
            )
            
            let newSureState = SendMoneyDstState(
                firstResponse: response,
                appContext: self.appContext,
                amount: matchingAmount,
                recipient: eventualMatchingRecipient,
                bankAccount: nil
            )
            
            stateChanger.changeDstState(to: newSureState)
            return response
        }
        
        // here every info is specified, but recipient and bank account might have more than one match
        // (precedence to recipient)
        
        if matchingRecipients.areMoreThanOne {
            // ask to choose among matching contacts, and go to the 'sure' state, saving any relevant state info, and eventually checking that the currency is coherent with the bank account
            
            let eventualMatchingBankAccount = matchingBankAccounts.count == 1 ? matchingBankAccounts[0] : nil
            
            if let bankAccount = eventualMatchingBankAccount,
               bankAccount.currency != matchingAmount.currency {
                // the specified bank account is not in the same currency as the specified amount -> ask to specify a correct amount
                                
                matchingNotFoundMessage = "Ok, but your \(bankAccount.name) account is not in \(matchingAmount.currency.literalPlural). Please specify an amount with a coherent currency."
                
                let response: VocalAssistantResponse = .justAnswer(
                    answer: matchingNotFoundMessage,
                    followUpQuestion: "How much do you want to send?"
                )
                
                let newSureState = SendMoneyDstState(
                    firstResponse: response,
                    appContext: self.appContext,
                    amount: nil,
                    recipient: nil,
                    bankAccount: bankAccount
                )
                stateChanger.changeDstState(to: newSureState)
                return response
            }
            
            let response: VocalAssistantResponse = .askToChooseContact(
                contacts: matchingRecipients,
                answer: "Ok, I've found multiple contacts matching your request.",
                followUpQuestion: "Who do you want to send this money to?"
            )
            
            let newSureState = SendMoneyDstState(
                firstResponse: response,
                appContext: self.appContext,
                amount: matchingAmount,
                recipient: nil,
                bankAccount: eventualMatchingBankAccount
            )
            
            stateChanger.changeDstState(to: newSureState)
            return response
        }
        
        let matchingRecipient = matchingRecipients[0]
        // here both amount and recipient have been specified, but the matching bank accounts might be more than one
        
        // check that the matching bank accounts have all the same currency as the specified one
        matchingBankAccounts = matchingBankAccounts.filter { $0.currency == matchingAmount.currency }
        
        guard matchingBankAccounts.isNotEmpty else {
            // all the matching accounts have a different currency than the one mentioned by the user
            
            let response: VocalAssistantResponse = .askToChooseBankAccount(
                bankAccounts: self.appContext.userBankAccounts.filter { $0.currency == matchingAmount.currency },
                answer: "Ok, but the mentioned bank account is not in \(matchingAmount.currency.literalPlural). Please specify a bank account with a coherent currency.",
                followUpQuestion: "Which of your bank accounts do you want to use?"
            )
            
            let newSureState = SendMoneyDstState(
                firstResponse: response,
                appContext: self.appContext,
                amount: matchingAmount,
                recipient: matchingRecipient,
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
            
            let newSureState = SendMoneyDstState(
                firstResponse: response,
                appContext: self.appContext,
                amount: matchingAmount,
                recipient: matchingRecipient,
                bankAccount: nil
            )
            
            stateChanger.changeDstState(to: newSureState)
            return response
        }
        
        let matchingBankAccount = matchingBankAccounts[0]

        // * here the amount is specified, with only one recipient, and only one (coherent) bank account *
        // go to the confirmation stage
        
        let response: VocalAssistantResponse = .sendMoneyConfirmationQuestion(
            answer: "Ok.",
            amount: matchingAmount,
            recipient: matchingRecipient,
            sourceBankAccount: matchingBankAccount
        )
        
        let newConfirmationState = ConfirmationSendMoneyDstState(
            lastResponse: response,
            amountToConfirm: matchingAmount,
            recipientToConfirm: matchingRecipient,
            sourceBankAccountToConfirm: matchingBankAccount,
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
