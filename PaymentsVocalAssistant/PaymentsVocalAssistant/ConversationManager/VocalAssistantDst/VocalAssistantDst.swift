//
//  PaymentsAssistantTextClassifier.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 17/01/24.
//

import Foundation

/**
 Object performing Intent classification and Dialogue State Tracking (DST) over the user speech's transcript
 */
public class VocalAssistantDst: DstStateChanger {
    // Machine Learning model extracting intent and entities from user transcripts
    internal let intentAndEntitiesExtractor: any IntentAndEntitiesExtractor
    
    // context
    private let appContext: AppContext
    private let defaultErrorMessage: String
    
    // conversation state
    private var currentState: DstState
    
    
    internal init(
        intentAndEntitiesExtractor: any IntentAndEntitiesExtractor,
        appContext: AppContext,
        defaultErrorMessage: String,
        startConversationMessage: String
    ) {
        self.intentAndEntitiesExtractor = intentAndEntitiesExtractor
        self.appContext = appContext
        self.defaultErrorMessage = defaultErrorMessage
        
        // default start state
        self.currentState = NoDstState(appContext: appContext, startConversationMessage: startConversationMessage)
    }
    
    internal func startConversation() -> String {
        return self.currentState.startSentence
    }
    
    /** Process user input transcript and generate output managing the conversation state */
    internal func request(_ userTranscript: String) -> VocalAssistantResponse {
        let recognitionResult = self.intentAndEntitiesExtractor.recognize(from: userTranscript)
    
        guard recognitionResult.isSuccess else {
            let errorMessage = recognitionResult.failure!.message
            return .appError(
                errorMessage: errorMessage,
                answer: defaultErrorMessage,
                followUpQuestion: self.currentState.lastResponse.followUpQuestion
            )
        }
                
        let prediction = recognitionResult.success!
        
        logSuccess("Predicted intent: \(prediction.predictedIntent.type) (\(prediction.predictedIntent.probability))")
        logSuccess("Predicted entities: [\(prediction.predictedEntities.map { "\($0.reconstructedEntity) (\($0.type) - \($0.entityProbability))" }.joined(separator: ", "))]")

        let response: VocalAssistantResponse
        
        switch prediction.predictedIntent.type {
        case .none:
            response = self.currentState.userExpressedNoneIntent(
                entities: prediction.predictedEntities,
                stateChanger: self
            )
        case .checkBalance:
            response = self.currentState.userExpressedCheckBalanceIntent(
                probability: prediction.predictedIntent.probability,
                entities: prediction.predictedEntities,
                stateChanger: self
            )
        case .checkTransactions:
            response = self.currentState.userExpressedCheckTransactionsIntent(
                probability: prediction.predictedIntent.probability,
                entities: prediction.predictedEntities,
                stateChanger: self
            )
        case .sendMoney:
            response = self.currentState.userExpressedSendMoneyIntent(
                probability: prediction.predictedIntent.probability,
                entities: prediction.predictedEntities,
                stateChanger: self
            )
        case .requestMoney:
            response = self.currentState.userExpressedRequestMoneyIntent(
                probability: prediction.predictedIntent.probability,
                entities: prediction.predictedEntities,
                stateChanger: self
            )
        case .yes:
            response = self.currentState.userExpressedYesIntent(
                probability: prediction.predictedIntent.probability,
                stateChanger: self
            )
        case .no:
            response = self.currentState.userExpressedNoIntent(
                probability: prediction.predictedIntent.probability,
                stateChanger: self
            )
        }
        
        // log the current state
        logInfo("Current DST state: \(self.currentState)")
        
        return response
    }
    
    /**
     Used when the user tap on and select a specific bank account
     */
    func select(bankAccount: VocalAssistantBankAccount) -> VocalAssistantResponse {
        let response = self.currentState.userSelected(
            bankAccount: bankAccount,
            stateChanger: self
        )
        
        // log the current state
        logInfo("Current DST state: \(self.currentState)")
        
        return response
    }
    
    func select(contact: VocalAssistantContact) -> VocalAssistantResponse {
        let response = self.currentState.userSelected(
            contact: contact,
            stateChanger: self
        )
        
        // log the current state
        logInfo("Current DST state: \(self.currentState)")
        
        return response
    }
    
    internal func changeDstState(to newDstState: DstState) {
        self.currentState = newDstState
    }
}
