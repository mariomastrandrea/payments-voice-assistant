//
//  DSTstate.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 01/02/24.
//

import Foundation

protocol DstState {
    var lastResponse: VocalAssistantResponse { get set }
    
    var startSentence: String { get }
    
    func userExpressedNoneIntent(probability: Float32, entities: [PaymentsEntity], stateChanger: DstStateChanger) -> VocalAssistantResponse
    
    func userExpressedCheckBalanceIntent(probability: Float32, entities: [PaymentsEntity], stateChanger: DstStateChanger) -> VocalAssistantResponse
    
    func userExpressedCheckTransactionsIntent(probability: Float32, entities: [PaymentsEntity], stateChanger: DstStateChanger) -> VocalAssistantResponse
    
    func userExpressedSendMoneyIntent(probability: Float32, entities: [PaymentsEntity], stateChanger: DstStateChanger) -> VocalAssistantResponse
    
    func userExpressedRequestMoneyIntent(probability: Float32, entities: [PaymentsEntity], stateChanger: DstStateChanger) -> VocalAssistantResponse
    
    func userExpressedYesIntent(probability: Float32, stateChanger: DstStateChanger) -> VocalAssistantResponse
    
    func userExpressedNoIntent(probability: Float32, stateChanger: DstStateChanger) -> VocalAssistantResponse
}


