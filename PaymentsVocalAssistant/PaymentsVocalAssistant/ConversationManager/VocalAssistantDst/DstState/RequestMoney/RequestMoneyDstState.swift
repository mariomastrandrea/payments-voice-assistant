//
//  RequestMoneyDstState.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 04/02/24.
//

import Foundation

class RequestMoneyDstState: DstState {
    var description: String {
        return "RequestMoneyDstState(amount: \(self.amount?.description ?? "nil"), sender: \(self.sender?.description ?? "nil"), bankAccount: \(self.bankAccount?.description ?? "nil"))"
    }
    
    var startSentence: String = ""
    internal var lastResponse: VocalAssistantResponse
    internal let appContext: AppContext
    
    // request money frame properties
    internal let amount: VocalAssistantAmount?
    internal let sender: VocalAssistantContact?
    internal let bankAccount: VocalAssistantBankAccount?

    
    init(
        firstResponse: VocalAssistantResponse,
        appContext: AppContext,
        amount: VocalAssistantAmount? = nil,
        sender: VocalAssistantContact? = nil,
        bankAccount: VocalAssistantBankAccount? = nil
    ) {
        self.lastResponse = firstResponse
        self.appContext = appContext
        self.amount = amount
        self.sender = sender
        self.bankAccount = bankAccount
    }
    
    internal static let threshold = DefaultVocalAssistantConfig.uncertaintyThreshold

    static func from(
        probability: Float32,
        entities: [PaymentsEntity],
        previousState: DstState,
        appContext: AppContext
    ) -> (state: RequestMoneyDstState?, firstResponse: VocalAssistantResponse) {
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
            exceedingEntitiesErrorMsg += exceedingEntitiesErrorMsg.isEmpty ? "Please specify just one sender" : " and just one sender"
        }
        
        if numConfidentBanks > 1 {
            // more than one bank has been specified by the user
            exceedingEntitiesErrorMsg += exceedingEntitiesErrorMsg.isEmpty ? "Please specify just one bank account" : " and just one bank account"
        }
        
        if exceedingEntitiesErrorMsg.isNotEmpty {
            // more entities than needed have been specified
            exceedingEntitiesErrorMsg += " to request some money."
            
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
                    followUpQuestion: "How much do you want to request?"
                )
                
                let newState = WaitAmountRequestMoneyDstState(firstResponse: response, appContext: appContext)
                return (newState, response)
            }
        }
        
        // retrieve the needed entities: amount, contact(sender) and bank account
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
        
        var selectedSender = userEntities.first { $0.entityProbability >= threshold }
        var selectedSenderUnsure = false
        
        if selectedSender == nil {
            // select the first with entity probability < threhsold (if any)
            selectedSender = userEntities.first
            if selectedSender != nil {
                selectedSenderUnsure = true
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
        if probability < threshold || selectedAmountUnsure || selectedSenderUnsure || selectedBankAccountUnsure {
            // something is not sure
            var question = "do you want to request"
            
            if selectedAmountUnsure, let amount = selectedAmount {
                question += " \(amount.reconstructedEntity)"
            }
            else {
                question += " some money"
            }
            
            if selectedSenderUnsure, let sender = selectedSender {
                question += " from \(sender.reconstructedEntity)"
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
            let unsureState = UnsureRequestMoneyDstState(
                lastResponse: response,
                previousState: previousState,
                possibleAmount: selectedAmount,
                possibleSender: selectedSender,
                possibleBankAccount: selectedBankAccount,
                appContext: appContext
            )
            
            return (unsureState, response)
        }
        
        // * every specified info is 'sure' here (and it is one at most) *
        // now look for matching entities
        
        var matchingAmount: VocalAssistantAmount?
        var matchingSenders = [VocalAssistantContact]()
        var matchingBankAccounts = [VocalAssistantBankAccount]()
        
        if let possibleAmount = selectedAmount {
            // an amount has been specified -> parse amount
            let possibleUniqueCurrencies = Array(Set(appContext.userBankAccounts.map { $0.currency }))
            
            matchingAmount = VocalAssistantAmount(
                fromEntity: possibleAmount.reconstructedEntity,
                possibleCurrencies: possibleUniqueCurrencies
            )
        }
        
        if let possibleSender = selectedSender {
            // a sender has been mentioned -> look for matching contacts
            matchingSenders = appContext.userContacts.keepAndOrderJustTheOnesSimilar(to: possibleSender.reconstructedEntity)
        }
        
        if let possibleBankAccount = selectedBankAccount {
            // a bank account has been mentioned -> look for matching bank account
            matchingBankAccounts = appContext.userBankAccounts.filter { bankAccount in
                bankAccount.match(with: possibleBankAccount.reconstructedEntity)
            }
        }
        else {
            // user did not mention any bank account, but if they have just one bank account, use it by default
            if appContext.userBankAccounts.count == 1 {
                matchingBankAccounts.append(appContext.userBankAccounts[0])
            }
        }
        
        // look for wrong matchings (misunderstandings)
        
        var matchingNotFoundMessages = [String]()
                
        if selectedAmount != nil && matchingAmount == nil {
            // amount has been mentioned but not quite understood
            matchingNotFoundMessages.append("I didn't quite understand how much you want to request (please specify the amount together with the correct currency)")
        }
        
        if selectedSender != nil && matchingSenders.isEmpty {
            // sender has been mentioned but not quite understood
            matchingNotFoundMessages.append("I didn't find any contact matching your request")
        }
        
        if selectedBankAccount != nil && matchingBankAccounts.isEmpty {
            // bank account has been mentioned but not quite understood
            matchingNotFoundMessages.append("I didn't find any bank account matching your request")
        }
        
        var matchingNotFoundMessage = matchingNotFoundMessages.joinGrammatically()
        if matchingNotFoundMessage.isNotEmpty {
            matchingNotFoundMessage = "Ok, but " + matchingNotFoundMessage + "."
        }
        
        // * priority to: amount -> sender -> bank account *
        
        guard let matchingAmount = matchingAmount else {
            // ask to specify the amount and return a new Request Money state, with any relevant state info
            
            let response: VocalAssistantResponse = .justAnswer(
                answer: matchingNotFoundMessage.isEmpty ? "Ok." : matchingNotFoundMessage,
                followUpQuestion: "How much do you want to request?"
            )
            
            // save sender and bank account only if there is just one match
            let eventualMatchingSender = matchingSenders.count == 1 ? matchingSenders[0] : nil
            let eventualMatchingBankAccount = matchingBankAccounts.count == 1 ? matchingBankAccounts[0] : nil
            
            let newState = WaitAmountRequestMoneyDstState(
                firstResponse: response,
                appContext: appContext,
                amount: nil,
                sender: eventualMatchingSender,
                bankAccount: eventualMatchingBankAccount
            )
            
            return (newState, response)
        }
        
        // (here amount is specified)
        
        if matchingSenders.isEmpty {
            // ask to specify the sender and return a new Request Money state, saving any relevant state info
            
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
                
                let newState = WaitAmountRequestMoneyDstState(
                    firstResponse: response,
                    appContext: appContext,
                    amount: nil,
                    sender: nil,
                    bankAccount: bankAccount
                )
                return (newState, response)
            }
            
            let response: VocalAssistantResponse = .justAnswer(
                answer: matchingNotFoundMessage.isEmpty ? "Ok." : matchingNotFoundMessage,
                followUpQuestion: "Who do you want to request this money from?"
            )
            
            let newState = WaitSenderRequestMoneyDstState(
                firstResponse: response,
                appContext: appContext,
                amount: matchingAmount,
                sender: nil,
                bankAccount: eventualMatchingBankAccount
            )
            
            return (newState, response)
        }
        
        // (here amount is specified and there are >= 1 specified senders)
        
        if matchingBankAccounts.isEmpty {
            // ask to specify the bank account and create a new Request Money state, with any relevant state info
            
            // save the sender only if it has been perfectly matched with only one contact
            let eventualMatchingSender = matchingSenders.count == 1 ? matchingSenders[0] : nil
            
            let response: VocalAssistantResponse = .justAnswer(
                answer: matchingNotFoundMessage.isEmpty ? "Ok." : matchingNotFoundMessage,
                followUpQuestion: "Which of your bank accounts do you want to use?\nYour bank accounts are at: \(appContext.userBankAccounts.map{$0.description}.joinGrammatically())"
            )
            
            let newState = WaitBankAccountRequestMoneyDstState(
                firstResponse: response,
                appContext: appContext,
                amount: matchingAmount,
                sender: eventualMatchingSender,
                bankAccount: nil
            )
            
            return (newState, response)
        }
        
        // here every info is specified, but sender and bank account might have more than one match
        // (precedence to sender)
        
        if matchingSenders.areMoreThanOne {
            // ask to choose among matching contacts, and create a new Request Money state, with any relevant state info, and eventually checking that the currency is coherent with the bank account
            
            let eventualMatchingBankAccount = matchingBankAccounts.count == 1 ? matchingBankAccounts[0] : nil
            
            if let bankAccount = eventualMatchingBankAccount,
               bankAccount.currency != matchingAmount.currency {
                // the specified bank account is not in the same currency as the specified amount -> ask to specify a correct amount
                                
                matchingNotFoundMessage = "Ok, but your \(bankAccount.name) account is not in \(matchingAmount.currency.literalPlural). Please specify an amount with a coherent currency."
                
                let response: VocalAssistantResponse = .justAnswer(
                    answer: matchingNotFoundMessage,
                    followUpQuestion: "How much do you want to request?"
                )
                
                let newState = WaitAmountRequestMoneyDstState(
                    firstResponse: response,
                    appContext: appContext,
                    amount: nil,
                    sender: nil,
                    bankAccount: bankAccount
                )
                return (newState, response)
            }
            
            let response: VocalAssistantResponse = .askToChooseContact(
                contacts: matchingSenders,
                answer: "Ok, I've found multiple contacts matching your request.",
                followUpQuestion: "Who do you want to request this money from?"
            )
            
            let newState = WaitSenderRequestMoneyDstState(
                firstResponse: response,
                appContext: appContext,
                amount: matchingAmount,
                sender: nil,
                bankAccount: eventualMatchingBankAccount
            )
            
            return (newState, response)
        }
        
        let matchingSender = matchingSenders[0]
        // here both amount and sender have been specified, but the matching bank accounts might be more than one
        
        // check that the matching bank accounts have all the same currency as the specified one
        matchingBankAccounts = matchingBankAccounts.filter { $0.currency == matchingAmount.currency }
        
        guard matchingBankAccounts.isNotEmpty else {
            // all the matching accounts have a different currency than the one mentioned by the user
            
            let response: VocalAssistantResponse = .askToChooseBankAccount(
                bankAccounts: appContext.userBankAccounts.filter { $0.currency == matchingAmount.currency },
                answer: "Ok, but the mentioned bank account is not in \(matchingAmount.currency.literalPlural). Please specify a bank account with a coherent currency.",
                followUpQuestion: "Which of your bank accounts do you want to use to request that money?"
            )
            
            let newState = WaitBankAccountRequestMoneyDstState(
                firstResponse: response,
                appContext: appContext,
                amount: matchingAmount,
                sender: matchingSender,
                bankAccount: nil
            )
            
            return (newState, response)
        }
        
        if matchingBankAccounts.areMoreThanOne {
            // ask to choose among matching bank accounts, and create a new Request Money state with the relevant info
            
            let response: VocalAssistantResponse = .askToChooseBankAccount(
                bankAccounts: matchingBankAccounts,
                answer: "Ok, I've found multiple bank accounts matching your request.",
                followUpQuestion: "Which one do you want to use to request that money?"
            )
            
            let newState = WaitBankAccountRequestMoneyDstState(
                firstResponse: response,
                appContext: appContext,
                amount: matchingAmount,
                sender: matchingSender,
                bankAccount: nil
            )
            
            return (newState, response)
        }
        
        let matchingBankAccount = matchingBankAccounts[0]

        // * here the amount is specified, with only one sender, and only one (coherent) bank account *
        // go to the confirmation stage
        
        let response: VocalAssistantResponse = .requestMoneyConfirmationQuestion(
            answer: "Got it.",
            amount: matchingAmount,
            sender: matchingSender,
            destinationBankAccount: matchingBankAccount
        )
        
        let newConfirmationState = ConfirmationRequestMoneyDstState(
            lastResponse: response,
            amountToConfirm: matchingAmount,
            senderToConfirm: matchingSender,
            destinationBankAccountToConfirm: matchingBankAccount,
            appContext: appContext
        )
        
        return (newConfirmationState, response)
    }
    
    
    func userExpressedNoneIntent(entities: [PaymentsEntity], stateChanger: DstStateChanger) -> VocalAssistantResponse {
        // do not change state -> user must express an intent here
        let response: VocalAssistantResponse = .justAnswer(
            answer: "Sorry, I cannot help you with that.",
            followUpQuestion: self.lastResponse.followUpQuestion
        )
        
        // update last response
        self.lastResponse = response
        
        return response
    }
    
    func userExpressedCheckBalanceIntent(probability: Float32, entities: [PaymentsEntity], stateChanger: DstStateChanger) -> VocalAssistantResponse {
        let (newCheckBalanceState, response) = CheckBalanceDstState.from(
            probability: probability,
            entities: entities,
            previousState: self,
            appContext: self.appContext
        )
        
        if let newState = newCheckBalanceState {
            stateChanger.changeDstState(to: newState)
        }
        
        self.lastResponse = response
        return response
    }
    
    func userExpressedCheckTransactionsIntent(probability: Float32, entities: [PaymentsEntity], stateChanger: DstStateChanger) -> VocalAssistantResponse {
        let (newState, response) = CheckTransactionsDstState.from(
            probability: probability,
            entities: entities,
            previousState: self,
            appContext: self.appContext
        )
        
        if let newState = newState {
            stateChanger.changeDstState(to: newState)
        }
        else {
            self.lastResponse = response
        }
        
        return response
    }
    
    func userExpressedSendMoneyIntent(probability: Float32, entities: [PaymentsEntity], stateChanger: DstStateChanger) -> VocalAssistantResponse {
        let (newState, response) = SendMoneyDstState.from(
            probability: probability,
            entities: entities,
            previousState: self,
            appContext: self.appContext
        )
        
        if let newState = newState {
            stateChanger.changeDstState(to: newState)
        }
        else {
            self.lastResponse = response
        }
        
        return response
    }
    
    func userExpressedRequestMoneyIntent(probability: Float32, entities: [PaymentsEntity], stateChanger: DstStateChanger) -> VocalAssistantResponse {
        let threshold = DefaultVocalAssistantConfig.uncertaintyThreshold
        
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
            exceedingEntitiesErrorMsg += exceedingEntitiesErrorMsg.isEmpty ? "Please specify just one sender" : " and just one sender"
        }
        
        if numConfidentBanks > 1 {
            // more than one bank has been specified by the user
            exceedingEntitiesErrorMsg += exceedingEntitiesErrorMsg.isEmpty ? "Please specify just one bank account" : " and just one bank account"
        }
        
        if exceedingEntitiesErrorMsg.isNotEmpty {
            // more entities than needed have been specified
            exceedingEntitiesErrorMsg += " to request some money."
            
            // do not create a new state, instead repeat the same question
            let response: VocalAssistantResponse = .justAnswer(
                answer: exceedingEntitiesErrorMsg,
                followUpQuestion: self.lastResponse.followUpQuestion
            )
            
            self.lastResponse = response
            return response
        }
        
        // retrieve the needed entities: amount, contact(sender) and bank account
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
        
        var selectedSender = userEntities.first { $0.entityProbability >= threshold }
        var selectedSenderUnsure = false
        
        if selectedSender == nil {
            // select the first with entity probability < threhsold (if any)
            selectedSender = userEntities.first
            if selectedSender != nil {
                selectedSenderUnsure = true
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
        if probability < threshold || selectedAmountUnsure || selectedSenderUnsure || selectedBankAccountUnsure {
            // something is not sure
            var question = "do you want to request"
            
            if selectedAmountUnsure, let amount = selectedAmount {
                question += " \(amount.reconstructedEntity)"
            }
            else {
                question += " some money"
            }
            
            if selectedSenderUnsure, let sender = selectedSender {
                question += " from \(sender.reconstructedEntity)"
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
            let unsureState = UnsureRequestMoneyDstState(
                lastResponse: response,
                previousState: self,
                // (keep the old selected entities)
                possibleAmount: selectedAmount ?? self.amount?.toEntity(),
                possibleSender: selectedSender ?? self.sender?.toEntity(),
                possibleBankAccount: selectedBankAccount ?? self.bankAccount?.toEntity(),
                appContext: self.appContext
            )
            
            stateChanger.changeDstState(to: unsureState)
            return response
        }
        
        // * every specified info is 'sure' here (and it is one at most) *
        // now look for matching entities
        
        var matchingAmount: VocalAssistantAmount?
        var matchingSenders = [VocalAssistantContact]()
        var matchingBankAccounts = [VocalAssistantBankAccount]()
        
        if let possibleAmount = selectedAmount {
            // an amount has been specified -> parse amount
            let possibleUniqueCurrencies = Array(Set(self.appContext.userBankAccounts.map { $0.currency }))
            
            matchingAmount = VocalAssistantAmount(
                fromEntity: possibleAmount.reconstructedEntity,
                possibleCurrencies: possibleUniqueCurrencies
            )
        }
        
        if let possibleSender = selectedSender {
            // a sender has been mentioned -> look for matching contacts
            matchingSenders = self.appContext.userContacts.keepAndOrderJustTheOnesSimilar(to: possibleSender.reconstructedEntity)
        }
        
        if let possibleBankAccount = selectedBankAccount {
            // a bank account has been mentioned -> look for matching bank accounts
            matchingBankAccounts = self.appContext.userBankAccounts.filter { bankAccount in
                bankAccount.match(with: possibleBankAccount.reconstructedEntity)
            }
        }
        
        // look for wrong matchings (misunderstandings)
        
        var matchingNotFoundMessages = [String]()
                
        if selectedAmount != nil && matchingAmount == nil {
            // amount has been mentioned but not quite understood
            matchingNotFoundMessages.append("I didn't quite understand how much you want to request (please specify the amount together with the correct currency)")
        }
        
        if selectedSender != nil && matchingSenders.isEmpty {
            // sender has been mentioned but not quite understood
            matchingNotFoundMessages.append("I didn't find any contact matching your request")
        }
        
        if selectedBankAccount != nil && matchingBankAccounts.isEmpty {
            // bank account has been mentioned but not quite understood
            matchingNotFoundMessages.append("I didn't find any bank account matching your request")
        }
        
        var matchingNotFoundMessage = matchingNotFoundMessages.joinGrammatically()
        if matchingNotFoundMessage.isNotEmpty {
            matchingNotFoundMessage = "Ok, but " + matchingNotFoundMessage + "."
        }
        
        // * re-use the old matched entities *
        
        // if the user mentioned an amount, use the found match, otherwise use the old amount (if any)
        if selectedAmount == nil {
            matchingAmount = self.amount
        }
        
        // if the user mentioned a sender, use the found match(es), otherwise keep just the old sender (if any)
        if selectedSender == nil {
            matchingSenders = self.sender == nil ? [] : [self.sender!]
        }
        
        // if the user mentioned a bank account, use the found match(es), otherwise keep just the old bank account (if any); if none, and there is just one account, fall back to that one
        if selectedBankAccount == nil {
            matchingBankAccounts = self.bankAccount != nil ? [self.bankAccount!] :
            (self.appContext.userBankAccounts.count == 1 ? [self.appContext.userBankAccounts[0]] : [])
        }
        
        // * priority to: amount -> sender -> bank account *
        
        guard let matchingAmount = matchingAmount else {
            // ask to specify the amount and go to new Wait Amount Request Money state, with any relevant state info
            
            let response: VocalAssistantResponse = .justAnswer(
                answer: matchingNotFoundMessage.isEmpty ? "Ok." : matchingNotFoundMessage,
                followUpQuestion: "How much do you want to request?"
            )
            
            // save sender and bank account only if there is just one match
            let eventualMatchingSender = matchingSenders.count == 1 ? matchingSenders[0] : nil
            let eventualMatchingBankAccount = matchingBankAccounts.count == 1 ? matchingBankAccounts[0] : nil
            
            let newState = WaitAmountRequestMoneyDstState(
                firstResponse: response,
                appContext: appContext,
                amount: nil,
                sender: eventualMatchingSender,
                bankAccount: eventualMatchingBankAccount
            )
            
            stateChanger.changeDstState(to: newState)
            return response
        }
        
        // (here amount is specified)
        
        if matchingSenders.isEmpty {
            // ask to specify the sender and return a new Request Money state, saving any relevant state info
            
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
                
                let newState = WaitAmountRequestMoneyDstState(
                    firstResponse: response,
                    appContext: self.appContext,
                    amount: nil,
                    sender: nil,
                    bankAccount: bankAccount
                )
                stateChanger.changeDstState(to: newState)
                return response
            }
            
            let response: VocalAssistantResponse = .justAnswer(
                answer: matchingNotFoundMessage.isEmpty ? "Ok." : matchingNotFoundMessage,
                followUpQuestion: "Who do you want to request this money from?"
            )
            
            let newState = WaitSenderRequestMoneyDstState(
                firstResponse: response,
                appContext: self.appContext,
                amount: matchingAmount,
                sender: nil,
                bankAccount: eventualMatchingBankAccount
            )
            
            stateChanger.changeDstState(to: newState)
            return response
        }
        
        // (here amount is specified and there are >= 1 specified senders)
        
        if matchingBankAccounts.isEmpty {
            // ask to specify the bank account and go to a new Request Money state, with any relevant state info
            
            // save the sender only if it has been perfectly matched with only one contact
            let eventualMatchingSender = matchingSenders.count == 1 ? matchingSenders[0] : nil
            
            let response: VocalAssistantResponse = .justAnswer(
                answer: matchingNotFoundMessage.isEmpty ? "Ok." : matchingNotFoundMessage,
                followUpQuestion: "Which of your bank accounts do you want to use?\nYour bank accounts are at: \(self.appContext.userBankAccounts.map{$0.description}.joinGrammatically())"
            )
            
            let newState = WaitBankAccountRequestMoneyDstState(
                firstResponse: response,
                appContext: self.appContext,
                amount: matchingAmount,
                sender: eventualMatchingSender,
                bankAccount: nil
            )
            
            stateChanger.changeDstState(to: newState)
            return response
        }
        
        // here every info is specified, but sender and bank account might have more than one match
        // (precedence to sender)
        
        if matchingSenders.areMoreThanOne {
            // ask to choose among matching contacts, and go to a new Request Money state, with any relevant state info, and eventually checking that the currency is coherent with the bank account
            
            let eventualMatchingBankAccount = matchingBankAccounts.count == 1 ? matchingBankAccounts[0] : nil
            
            if let bankAccount = eventualMatchingBankAccount,
               bankAccount.currency != matchingAmount.currency {
                // the specified bank account is not in the same currency as the specified amount -> ask to specify a correct amount
                                
                matchingNotFoundMessage = "Ok, but your \(bankAccount.name) account is not in \(matchingAmount.currency.literalPlural). Please specify an amount with a coherent currency."
                
                let response: VocalAssistantResponse = .justAnswer(
                    answer: matchingNotFoundMessage,
                    followUpQuestion: "How much do you want to request?"
                )
                
                let newState = WaitAmountRequestMoneyDstState(
                    firstResponse: response,
                    appContext: self.appContext,
                    amount: nil,
                    sender: nil,
                    bankAccount: bankAccount
                )
                
                stateChanger.changeDstState(to: newState)
                return response
            }
            
            let response: VocalAssistantResponse = .askToChooseContact(
                contacts: matchingSenders,
                answer: "Ok, I've found multiple contacts matching your request.",
                followUpQuestion: "Who do you want to request this money from?"
            )
            
            let newState = WaitSenderRequestMoneyDstState(
                firstResponse: response,
                appContext: self.appContext,
                amount: matchingAmount,
                sender: nil,
                bankAccount: eventualMatchingBankAccount
            )
            
            stateChanger.changeDstState(to: newState)
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
            
            let newState = WaitBankAccountRequestMoneyDstState(
                firstResponse: response,
                appContext: self.appContext,
                amount: matchingAmount,
                sender: matchingSender,
                bankAccount: nil
            )
            
            stateChanger.changeDstState(to: newState)
            return response
        }
        
        if matchingBankAccounts.areMoreThanOne {
            // ask to choose among matching bank accounts, and go to a new Request Money state with the relevant info
            
            let response: VocalAssistantResponse = .askToChooseBankAccount(
                bankAccounts: matchingBankAccounts,
                answer: "Ok, I've found multiple bank accounts matching your request.",
                followUpQuestion: "Which one do you want to use to request that money?"
            )
            
            let newState = WaitBankAccountRequestMoneyDstState(
                firstResponse: response,
                appContext: self.appContext,
                amount: matchingAmount,
                sender: matchingSender,
                bankAccount: nil
            )
            
            stateChanger.changeDstState(to: newState)
            return response
        }
        
        let matchingBankAccount = matchingBankAccounts[0]

        // * here the amount is specified, with only one sender, and only one (coherent) bank account *
        // go to the confirmation stage
        
        let response: VocalAssistantResponse = .requestMoneyConfirmationQuestion(
            answer: "Got it.",
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
    
    func userExpressedYesIntent(probability: Float32, stateChanger: DstStateChanger) -> VocalAssistantResponse {
        let response: VocalAssistantResponse = .justAnswer(
            answer: "Sorry, I didn't quite understand.",
            followUpQuestion: self.lastResponse.followUpQuestion
        )
        self.lastResponse = response
        return response
    }
    
    func userExpressedNoIntent(probability: Float32, stateChanger: DstStateChanger) -> VocalAssistantResponse {
        let response: VocalAssistantResponse = .justAnswer(
            answer: "Sorry, I didn't quite understand.",
            followUpQuestion: self.lastResponse.followUpQuestion
        )
        self.lastResponse = response
        return response
    }
}
