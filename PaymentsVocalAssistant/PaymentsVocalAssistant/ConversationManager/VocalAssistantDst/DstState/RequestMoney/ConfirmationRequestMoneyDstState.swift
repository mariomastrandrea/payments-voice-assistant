//
//  ConfirmationRequestMoneyDstState.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 04/02/24.
//

import Foundation

class ConfirmationRequestMoneyDstState: RequestMoneyDstState {
    override var description: String {
        return "ConfirmationRequestMoneyDstState(amountToConfirm: \(self.amountToConfirm.descriptionWithoutSign), senderToConfirm: \(self.senderToConfirm), destinationBankAccountToConfirm: \(self.destinationBankAccountToConfirm.name))"
    }
    
    private let amountToConfirm: VocalAssistantAmount
    private let senderToConfirm: VocalAssistantContact
    private let destinationBankAccountToConfirm: VocalAssistantBankAccount
    
    
    init(lastResponse: VocalAssistantResponse, amountToConfirm: VocalAssistantAmount, senderToConfirm: VocalAssistantContact, destinationBankAccountToConfirm: VocalAssistantBankAccount, appContext: AppContext) {
        self.amountToConfirm = amountToConfirm
        self.senderToConfirm = senderToConfirm
        self.destinationBankAccountToConfirm = destinationBankAccountToConfirm
        
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
        // user *confirmed* the request -> execute the request money operation and go to the NoDstState
        
        let response: VocalAssistantResponse = .requestMoneyOperation(
            amount: self.amountToConfirm,
            sender: self.senderToConfirm,
            bankAccount: self.destinationBankAccountToConfirm
        )
        
        // go back to NO state
        let noState = NoDstState(appContext: self.appContext, firstResponse: response)
        stateChanger.changeDstState(to: noState)
       
        return response
    }
    
    override func userExpressedNoIntent(probability: Float32, stateChanger: DstStateChanger) -> VocalAssistantResponse {
        // do not execute the request and go to the NoDstState

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
