//
//  SendMoneyDstState.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 03/02/24.
//

import Foundation

class SendMoneyDstState: DstState {
    var description: String {
        return "SendMoneyDstState()"
    }
    
    var startSentence: String = ""
    var lastResponse: VocalAssistantResponse
    internal let appContext: AppContext
    
    // send money frame properties
    private let amount: VocalAssistantAmount?
    private let receiver: VocalAssistantContact?
    private let bankAccount: VocalAssistantBankAccount?

    
    init(firstResponse: VocalAssistantResponse, appContext: AppContext, amount: VocalAssistantAmount? = nil, receiver: VocalAssistantContact? = nil, bankAccount: VocalAssistantBankAccount? = nil) {
        self.lastResponse = firstResponse
        self.appContext = appContext
        self.amount = amount
        self.receiver = receiver
        self.bankAccount = bankAccount
    }
    
    internal static let threshold = DefaultVocalAssistantConfig.uncertaintyThreshold

    static func from(
        probability: Float32,
        entities: [PaymentsEntity],
        previousState: DstState,
        appContext: AppContext
    ) -> (state: SendMoneyDstState?, firstResponse: VocalAssistantResponse) {
        // look for amount, user and bank entities
        
        
        
        
        // TODO: implement method
        return (state: nil, .appError(errorMessage: "todo", answer: "todo", followUpQuestion: "todo"))
    }
    
    
    func userExpressedNoneIntent(entities: [PaymentsEntity], stateChanger: DstStateChanger) -> VocalAssistantResponse {
        // TODO: implement method
        return .appError(errorMessage: "todo", answer: "todo", followUpQuestion: "todo")
    }
    
    func userExpressedCheckBalanceIntent(probability: Float32, entities: [PaymentsEntity], stateChanger: DstStateChanger) -> VocalAssistantResponse {
        // TODO: implement method
        return .appError(errorMessage: "todo", answer: "todo", followUpQuestion: "todo")
    }
    
    func userExpressedCheckTransactionsIntent(probability: Float32, entities: [PaymentsEntity], stateChanger: DstStateChanger) -> VocalAssistantResponse {
        // TODO: implement method
        return .appError(errorMessage: "todo", answer: "todo", followUpQuestion: "todo")
    }
    
    func userExpressedSendMoneyIntent(probability: Float32, entities: [PaymentsEntity], stateChanger: DstStateChanger) -> VocalAssistantResponse {
        // TODO: implement method
        return .appError(errorMessage: "todo", answer: "todo", followUpQuestion: "todo")
    }
    
    func userExpressedRequestMoneyIntent(probability: Float32, entities: [PaymentsEntity], stateChanger: DstStateChanger) -> VocalAssistantResponse {
        // TODO: implement method
        return .appError(errorMessage: "todo", answer: "todo", followUpQuestion: "todo")
    }
    
    func userExpressedYesIntent(probability: Float32, stateChanger: DstStateChanger) -> VocalAssistantResponse {
        // TODO: implement method
        return .appError(errorMessage: "todo", answer: "todo", followUpQuestion: "todo")
    }
    
    func userExpressedNoIntent(probability: Float32, stateChanger: DstStateChanger) -> VocalAssistantResponse {
        // TODO: implement method
        return .appError(errorMessage: "todo", answer: "todo", followUpQuestion: "todo")
    }
}
