//
//  BertModelConfig.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 16/01/24.
//

import Foundation

enum BertConfig {
    static let sequenceLength = 128
    static let doLowerCase = true

    static let inputDimension = [1, BertConfig.sequenceLength]
    static let outputDimension = [1, BertConfig.sequenceLength]
        
    // models
    static let miniBertModelFileName = "vocal_assistant_bert_mini_classifier"
    static let smallBertModelFileName = "vocal_assistant_bert_small_classifier"
    static let mediumBertModelFileName = "vocal_assistant_bert_medium_classifier"
    
    // resources
    static let vocabularyFile = File(name: "vocab", extension: "txt")
    static let modelFile = File(name: mediumBertModelFileName, extension: "tflite")
    
    // special tokens
    static let startOfSequenceToken = "[CLS]"
    static let sentenceSeparatorToken = "[SEP]"
    static let subtokenIdentifier = "##"
    
    // thresholds
    
    /** In order to be considered valid, an intent must exceed this threshold probability , */
    static let intentClassificationProbabilityThreshold: Float32 = 0.5
    
    /** In order to be considered valid, an entity label must exceed this threshold probability , */
    static let entityClassificationProbabilityThreshold: Float32 = 0.5
    
    /** In order to be considered valid, an entity must globally exceed this threshold probability , */
    static let entityGlobalProbabilityThreshold: Float32 = 0.5
    
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
