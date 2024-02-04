//
//  ConfirmationSendMoneyDstState.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 04/02/24.
//

import Foundation

class ConfirmationSendMoneyDstState: SendMoneyDstState {
    override var description: String {
        return "ConfirmationSendMoneyDstState(amountToConfirm: \(self.amountToConfirm.descriptionWithoutSign), recipientToConfirm: \(self.recipientToConfirm), sourceBankAccountToConfirm: \(self.sourceBankAccountToConfirm.name))"
    }
    
    private let amountToConfirm: VocalAssistantAmount
    private let recipientToConfirm: VocalAssistantContact
    private let sourceBankAccountToConfirm: VocalAssistantBankAccount
    
    
    init(lastResponse: VocalAssistantResponse, amountToConfirm: VocalAssistantAmount, recipientToConfirm: VocalAssistantContact, sourceBankAccountToConfirm: VocalAssistantBankAccount, appContext: AppContext) {
        self.amountToConfirm = amountToConfirm
        self.recipientToConfirm = recipientToConfirm
        self.sourceBankAccountToConfirm = sourceBankAccountToConfirm
        
        super.init(firstResponse: lastResponse, appContext: appContext)
    }
    
    override func userExpressedNoneIntent(entities: [PaymentsEntity], stateChanger: DstStateChanger) -> VocalAssistantResponse {
        // do not change state -> user must express an intent here
        let response: VocalAssistantResponse = .justAnswer(
            answer: "Sorry, I cannot help you with that.",
            followUpQuestion: self.lastResponse.followUpQuestion
        )
        
        // update last response
        self.lastResponse = response
        
        return response
    }
    
    override func userExpressedYesIntent(probability: Float32, stateChanger: DstStateChanger) -> VocalAssistantResponse {
        // user *confirmed* the payment -> execute the send money operation and go to the NoDstState
        
        let response: VocalAssistantResponse = .sendMoneyOperation(
            amount: self.amountToConfirm,
            recipient: self.recipientToConfirm,
            bankAccount: self.sourceBankAccountToConfirm
        )
        
        // go back to NO state
        let noState = NoDstState(appContext: self.appContext, firstResponse: response)
        stateChanger.changeDstState(to: noState)
       
        return response
    }
    
    override func userExpressedNoIntent(probability: Float32, stateChanger: DstStateChanger) -> VocalAssistantResponse {
        // do not execute the payment and go to the NoDstState

        let response: VocalAssistantResponse = .justAnswer(
            answer: "Ok, I won't do that.",
            followUpQuestion: "If you have any other request, I'm here to help you."
        )
        
        // go back to NO state
        let noState = NoDstState(appContext: self.appContext, firstResponse: response)
        stateChanger.changeDstState(to: noState)
        
        return response
    }
}
