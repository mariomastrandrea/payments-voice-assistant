//
//  UnsureCheckTransactionsDstState.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 02/02/24.
//

import Foundation

class UnsureCheckTransactionsDstState: CheckTransactionsDstState {
    override var description: String {
        return "UnsureCheckTransactionsDstState()"
    }
    
    private var previousState: DstState
    private var possibleBankAccount: PaymentsEntity?
    private var possibleContact: PaymentsEntity?
    
    init(lastResponse: VocalAssistantResponse, previousState: DstState, possibleBankAccount: PaymentsEntity? = nil, possibleContact: PaymentsEntity? = nil, appContext: AppContext) {
        self.previousState = previousState
        self.possibleBankAccount = possibleBankAccount
        self.possibleContact = possibleContact
        
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
    
    
    
    
}
