//
//  BertModelConfig.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 16/01/24.
//

import Foundation

enum BertTextClassifierConfig {
    static let maxNumTokens = 128
    static let doLowerCase = true

    static let inputDimension = [1, BertTextClassifierConfig.maxNumTokens]
    static let outputDimension = [1, BertTextClassifierConfig.maxNumTokens]
    
    // bert model file names
    static let bert_model_name = "vocal_assistant_bert_model"
    
    // resources
    static let vocabulary = File(name: "vocab", extension: "txt")
    static let model = File(name: bert_model_name, extension: "tflite")
    
    // special tokens
    static let startOfSequenceToken = "[CLS]"
    static let sentenceSeparatorToken = "[SEP]"
    
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
