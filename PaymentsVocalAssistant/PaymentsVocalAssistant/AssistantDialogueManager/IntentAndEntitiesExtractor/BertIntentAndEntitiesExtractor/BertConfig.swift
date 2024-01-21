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
        
    // resources
    static let vocabularyFile = File(name: "vocab", extension: "txt")
    static let modelFile = File(name: "vocal_assistant_bert_classifier", extension: "tflite")
    
    // special tokens
    static let startOfSequenceToken = "[CLS]"
    static let sentenceSeparatorToken = "[SEP]"
    
    // thresholds
    static let intentClassificationProbabilityThreshold: Float32 = 0.5
    static let entityClassificationProbabilityThreshold: Float32 = 0.5
    
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
