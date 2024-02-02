//
//  NoDSTstate.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 01/02/24.
//

import Foundation

class NoDstState: DstState {
    private static let defaultStart = "How can I help you?"
    var lastResponse: VocalAssistantResponse
    
    private let appContext: AppContext
    private let startConversationMessage: String
    
    var startSentence: String {
        return self.startConversationMessage + " " + NoDstState.defaultStart
    }

    init(appContext: AppContext, startConversationMessage: String) {
        self.appContext = appContext
        self.startConversationMessage = startConversationMessage
        
        self.lastResponse = .justAnswer(answer: startConversationMessage, followUpQuestion: NoDstState.defaultStart)
    }
    
    func userExpressedNoneIntent(probability: Float32, entities: [PaymentsEntity], stateChanger: DstStateChanger) -> VocalAssistantResponse {
        // state does not change -> wait for an expressed intent
        let response = VocalAssistantResponse.justAnswer(
            answer: DefaultVocalAssistantConfig.DST.intentNotChosenResponse,
            followUpQuestion: self.lastResponse.followUpQuestion
        )
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
        // TODO: implement method
        return .appError(errorMessage: "", answer: "", followUpQuestion: "")
    }
    
    func userExpressedSendMoneyIntent(probability: Float32, entities: [PaymentsEntity], stateChanger: DstStateChanger) -> VocalAssistantResponse {
        // TODO: implement method
        return .appError(errorMessage: "", answer: "", followUpQuestion: "")
    }
    
    func userExpressedRequestMoneyIntent(probability: Float32, entities: [PaymentsEntity], stateChanger: DstStateChanger) -> VocalAssistantResponse {
        // TODO: implement method
        return .appError(errorMessage: "", answer: "", followUpQuestion: "")
    }
    
    func userExpressedYesIntent(probability: Float32, stateChanger: DstStateChanger) -> VocalAssistantResponse {
        // state does not change -> wait for an expressed intent
        let response: VocalAssistantResponse = .justAnswer(
            answer: DefaultVocalAssistantConfig.DST.intentNotChosenResponse,
            followUpQuestion: self.lastResponse.followUpQuestion
        )
        self.lastResponse = response
        return response
    }
    
    func userExpressedNoIntent(probability: Float32, stateChanger: DstStateChanger) -> VocalAssistantResponse {
        // state does not change -> wait for an expressed intent
        let response: VocalAssistantResponse = .justAnswer(
            answer: DefaultVocalAssistantConfig.DST.intentNotChosenResponse,
            followUpQuestion: self.lastResponse.followUpQuestion
        )
        self.lastResponse = response
        return response
    }
}
