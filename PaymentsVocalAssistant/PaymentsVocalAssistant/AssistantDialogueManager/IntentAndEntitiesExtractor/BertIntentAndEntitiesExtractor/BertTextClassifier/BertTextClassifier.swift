//
//  BertTextClassifierModel.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 16/01/24.
//

import Foundation

class BertTextClassifier: IntentAndEntitiesClassifier {
    typealias Preprocessor = BertPreprocessor
    typealias Model = BertTFLiteIntentClassifierEntityExtractor
    typealias Labeler = IntentEntityLabeler

    var preprocessor: BertPreprocessor
    var model: BertTFLiteIntentClassifierEntityExtractor
    var labeler: IntentEntityLabeler
    
    init(
        preprocessor: BertPreprocessor,
        model: BertTFLiteIntentClassifierEntityExtractor,
        labeler: IntentEntityLabeler
    ) {
        self.preprocessor = preprocessor
        self.model = model
        self.labeler = labeler
    }
    
    func classify(text: String) -> (input: BertInput, output: IntentAndEntitiesRawLabels) {
        let t0 = Date()
        
        // preprocess input
        let encodedText = self.preprocessor.preprocess(text: text)
        
        let t_after_preprocessing = Date()
        let ms_after_preprocessing = 1000.0 * t_after_preprocessing.timeIntervalSince(t0)
        log("Preprocessing time: \(ms_after_preprocessing) ms")
        
        // process input data and produce the model raw output
        let modelOutput = self.model.execute(input: encodedText)
        
        let t_after_inference = Date()
        let ms_after_inference = 1000.0 * t_after_inference.timeIntervalSince(t_after_preprocessing)
        log("Inference time: \(ms_after_inference) ms")
        
        // assign labels from the model raw output
        let modelPrediction = self.labeler.predictLabels(from: modelOutput)
        
        let t_after_prediction = Date()
        let total_ms_for_classification = 1000.0 * t_after_prediction.timeIntervalSince(t0)
        log("Total classification time: \(total_ms_for_classification) ms")
        
        return (
            input:  encodedText,
            output: modelPrediction
        )
    }
}
