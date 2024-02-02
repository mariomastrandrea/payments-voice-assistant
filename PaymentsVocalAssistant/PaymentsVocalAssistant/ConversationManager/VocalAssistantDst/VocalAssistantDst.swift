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
        
        switch prediction.predictedIntent.type {
        case .none:
            return self.currentState.userExpressedNoneIntent(
                probability: prediction.predictedIntent.probability,
                entities: prediction.predictedEntities,
                stateChanger: self
            )
        case .checkBalance:
            return self.currentState.userExpressedCheckBalanceIntent(
                probability: prediction.predictedIntent.probability,
                entities: prediction.predictedEntities,
                stateChanger: self
            )
        case .checkTransactions:
            return self.currentState.userExpressedCheckTransactionsIntent(
                probability: prediction.predictedIntent.probability,
                entities: prediction.predictedEntities,
                stateChanger: self
            )
        case .sendMoney:
            return self.currentState.userExpressedSendMoneyIntent(
                probability: prediction.predictedIntent.probability,
                entities: prediction.predictedEntities,
                stateChanger: self
            )
        case .requestMoney:
            return self.currentState.userExpressedRequestMoneyIntent(
                probability: prediction.predictedIntent.probability,
                entities: prediction.predictedEntities,
                stateChanger: self
            )
        case .yes:
            return self.currentState.userExpressedYesIntent(
                probability: prediction.predictedIntent.probability,
                stateChanger: self
            )
        case .no:
            return self.currentState.userExpressedNoIntent(
                probability: prediction.predictedIntent.probability,
                stateChanger: self
            )
        }
        
        /*
        if predictedIntent.isSomeOperationIntent {
            // send_money, request_money, check_balance, check_transactions
            if predictedIntent.type != self.currentUserIntentFrame?.intentType {
                // * the user expressed a new (different) intent: change and create a new Frame *
                self.currentUserIntentFrame = predictedIntent.type.toNewFrame()
            }
        }
        
        guard let currentUserIntentFrame = self.currentUserIntentFrame else {
            // * the user did not express any valid intent *
            return .followUpQuestion(question: DefaultVocalAssistantConfig.DST.intentNotChosenResponse)
        }
         */
        
        // distinguish between yes, no, none 
        
        // TODO: check intent probability, if below threshold ask to confirm the intent
        
        
        /* TODO: (later) perform matching between the found entities and all the possible ones, like possible banks and user contacts */
    }
    
    func changeDstState(to newDstState: DstState) {
        self.currentState = newDstState
    }
}
