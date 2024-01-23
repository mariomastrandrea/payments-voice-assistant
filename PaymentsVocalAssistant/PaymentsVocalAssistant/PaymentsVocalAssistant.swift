//
//  PaymentsVocalAssistant.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 23/01/24.
//

import Foundation

public enum AssistantModelType {
    case bert
}

public class PaymentsVocalAssistant {
    private let intentAndEntitiesExtractor: any IntentAndEntitiesExtractor
    
    init?(type: AssistantModelType = .bert) {
        // initialize a Intent and Entities Extractor
        switch type {
            case .bert:
                guard let intentAndEntitiesExtractor =
                        PaymentsVocalAssistant.createBertIntentAndEntitiesExtractor() else { return nil }
                self.intentAndEntitiesExtractor = intentAndEntitiesExtractor
            }
    }
    
    /**
     Create a new instance of BERT extractor injecting all its dependencies
     */
    private static func createBertIntentAndEntitiesExtractor() -> BertIntentAndEntitiesExtractor? {
        // create BERT Preprocessor
        guard let bertTokenizer = BertTokenizer() else { return nil }
        
        let bertPreprocessor = BertPreprocessor(tokenizer: bertTokenizer)
        logSuccess("* created BERT preprocessor * ")
        
        // create BERT model
        guard let bertModel = BertTFLiteIntentAndEntitiesClassifier(
            tfLiteModelFile: BertConfig.modelFile
        )
        else { return nil }
        logSuccess("* created TF Lite BERT classifier *")
           
        // create BERT labeler
        let bertLabeler = BertIntentEntityLabeler()
        
        // create BERT text classifier
        let bertTextClassifier = BertTextClassifier(
            preprocessor: bertPreprocessor,
            model: bertModel,
            labeler: bertLabeler
        )
        
        // create the BERT intent and entities extractor
        let bertExtractor = BertIntentAndEntitiesExtractor(classifier: bertTextClassifier)
        logSuccess("* created BERT intent and entities extractor * ")
        
        return bertExtractor
    }
    
    /**
     Create a new conversation and get the corresponding dialogue manager
     */
    public func newConversation(userContacts: [Any] = [], userBankAccounts: [Any] = []) -> AssistantDialogueManager {
        // TODO: use proper high level app info: user contacts and user bank accounts

        return AssistantDialogueManager(
            intentAndEntitiesExtractor: self.intentAndEntitiesExtractor,
            userContacts: userContacts,
            userBankAccounts: userBankAccounts
        )
    }
}
