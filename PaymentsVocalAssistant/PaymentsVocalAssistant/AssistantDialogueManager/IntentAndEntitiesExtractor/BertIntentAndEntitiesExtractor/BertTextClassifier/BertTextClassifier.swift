//
//  BertTextClassifierModel.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 16/01/24.
//

import Foundation

class BertTextClassifier: IntentAndEntitiesClassifier {
    typealias Preprocessor = BertPreprocessor
    typealias Model = BertTFLiteIntentAndEntitiesClassifier
    typealias Labeler = IntentEntityLabeler

    var preprocessor: BertPreprocessor
    var model: BertTFLiteIntentAndEntitiesClassifier
    var labeler: IntentEntityLabeler
    
    init(
        preprocessor: BertPreprocessor,
        model: BertTFLiteIntentAndEntitiesClassifier,
        labeler: IntentEntityLabeler
    ) {
        self.preprocessor = preprocessor
        self.model = model
        self.labeler = labeler
    }
    
    func classify(text: String) -> BertExtractorResult<(input: BertInput, output: IntentAndEntitiesRawLabels)> {
        let t0 = Date()
        
        // 1. preprocess the input text to make it suitable for the BERT model
        let preprocessingResult = logElapsedTimeInMs(of: "preprocessing") {
            self.preprocessor.preprocess(text: text)
        }
        
        guard let encodedText = preprocessingResult.success else {
            return preprocessingResult.failureResult()
        }
        
        // 2. process input data and produce the model raw output
        let inferenceResult = logElapsedTimeInMs(of: "inference") {
            self.model.execute(input: encodedText)
        }
        
        guard let modelOutputProbabilities = inferenceResult.success else {
            return inferenceResult.failureResult()
        }
        
        // 3. assign labels from the model raw output
        let labellingResult = logElapsedTimeInMs(of: "entire classification", since: t0) {
            self.labeler.predictLabels(from: modelOutputProbabilities)
        }
        
        guard let modelPrediction = labellingResult.success else {
            return labellingResult.failureResult()
        }
        
        return .success((
            input:  encodedText,
            output: modelPrediction
        ))
    }
}
