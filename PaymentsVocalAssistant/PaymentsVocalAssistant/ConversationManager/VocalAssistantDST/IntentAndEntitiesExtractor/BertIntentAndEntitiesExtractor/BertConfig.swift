//
//  BertModelConfig.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 16/01/24.
//

import Foundation

enum BertConfig {
    enum ModelType {
        case mini
        case small
        case medium
        
        var fileName: String {
            return "vocal_assistant_bert_\(self)_classifier"
        }
    }
    
    // ** Select BERT model **
    static let selectedModel: ModelType = .medium
    
    static let sequenceLength = 128
    static let doLowerCase = true

    static let inputDimension = [1, BertConfig.sequenceLength]
    static let outputDimension = [1, BertConfig.sequenceLength]
    
    // special tokens
    static let startOfSequenceToken = "[CLS]"
    static let sentenceSeparatorToken = "[SEP]"
    static let subtokenIdentifier = "##"
    
    // resources
    static let vocabularyFile = File(name: "vocab", extension: "txt")
    static let modelFile = File(name: selectedModel.fileName, extension: "tflite")
    
    // thresholds
    
    /** In order to be considered valid, an intent must exceed this threshold probability , */
    static let intentClassificationProbabilityThreshold: Float32 = 0.5
    
    /** In order to be considered valid, an entity label must exceed this threshold probability , */
    static let entityClassificationProbabilityThreshold: Float32 = 0.5
    
    /** In order to be considered valid, an entity must globally exceed this threshold probability , */
    static let entityGlobalProbabilityThreshold: Float32 = 0.5
    
    // entities reconstruction
    static let punctuationSymbolsToJoin: [String] = [",", ".", "'", "-"]
    
    enum TfLite {
        // TF Lite model inputs
        static let inputWordIdsIndex = 0
        static let inputTypeIdsIndex = 1
        static let inputMaskIndex = 2
        
        // TF Lite model outputs
        static let outputIntentRecognitionIndex = 0
        static let outputEntityExtractionIndex = 1
    }
}
