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
    // singleton instance
    private static var _instance: PaymentsVocalAssistant? = nil
    private static let type: AssistantModelType = .bert
    
    // app context
    private var userContacts: [VocalAssistantContact]
    private var userBankAccounts: [VocalAssistantBankAccount]
    
    private let intentAndEntitiesExtractor: any IntentAndEntitiesExtractor
    private let speechRecognizer: SpeechRecognizer
    private let speechSynthesizer: SpeechSynthesizer
    
    
    /**
     Initialize the Vocal Assistant specifying the requested type
     
     Call this method just once, at app initialization time
     */
    private init?(
        userContacts: [VocalAssistantContact],
        userBankAccounts: [VocalAssistantBankAccount]
    ) async {
        // initialize a Intent and Entities Extractor
        switch PaymentsVocalAssistant.type {
            case .bert:
                guard let intentAndEntitiesExtractor =
                        PaymentsVocalAssistant.createBertIntentAndEntitiesExtractor() else { return nil }
                self.intentAndEntitiesExtractor = intentAndEntitiesExtractor
            }
        
        // initialize speech recognizer, eventually with a Custom Language model (iOS >=17)
        guard let speechRecognizer = await SpeechRecognizer() else { return nil }
        self.speechRecognizer = speechRecognizer
        
        await self.speechRecognizer.createCustomLM(
            names: userContacts.compactMap { $0.firstName.isEmpty ? nil : $0.firstName },
            surnames: userContacts.compactMap { $0.lastName.isEmpty ? nil : $0.lastName },
            banks: userBankAccounts.map { $0.name }
        )
        
        // initialize speech synthesizer
        self.speechSynthesizer = SpeechSynthesizer()
        
        // save app context
        self.userContacts = userContacts
        self.userBankAccounts = userBankAccounts
    }
    
    /** Return the singleton instance of the Vocal Assistant.
     
        If this is the first time the method is called, it instantiates and initializes the
        Vocal Assistant with its subcomponents, so this call might take a long time */
    public static func instance(
        userContacts: [VocalAssistantContact] = [],
        userBankAccounts: [VocalAssistantBankAccount] = []
    ) async -> PaymentsVocalAssistant? {
        if _instance == nil {
            _instance = await PaymentsVocalAssistant(
                userContacts: userContacts,
                userBankAccounts: userBankAccounts
            )
        }
        else {
            // just update the app context
            _instance?.userContacts = userContacts
            _instance?.userBankAccounts = userBankAccounts
        }
        
        return _instance
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
     Create a new conversation and get the corresponding dialogue manager, providing the user's app context
     - parameter userContacts: list of the contacts which might be referred by the user in the conversation
     - parameter userBankAccounts: list of the bank accounts the user can use to perform in-app operations
     
     Call this method each time the user is starting a new conversation
     */
    public func newConversation(
        withMessage startConversationMessage: String,
        andDefaultErrorMessage defaultErrorMessage: String
    ) -> ConversationManager {
        // create a new DST dependency to manage the new conversation
        let dst = VocalAssistantDST(
            intentAndEntitiesExtractor: self.intentAndEntitiesExtractor,
            userContacts: self.userContacts,
            userBankAccounts: self.userBankAccounts
        )
        
        return ConversationManager(
            speechRecognizer: self.speechRecognizer,
            dst: dst,
            speechSyntesizer: self.speechSynthesizer,
            defaultErrorMessage: defaultErrorMessage,
            startConversationMessage: startConversationMessage
        )
    }
}
