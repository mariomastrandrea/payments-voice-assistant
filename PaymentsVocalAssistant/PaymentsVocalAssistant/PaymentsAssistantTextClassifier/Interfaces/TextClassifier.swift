//
//  TextClassifier.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 17/01/24.
//

import Foundation

/**
 A generic interface for a Text Classifier
 */
protocol TextClassifier {
    associatedtype Preprocessor: TextPreprocessor
    
    // Preprocessor output must be compatible with the Model input
    associatedtype Model: MachineLearningModel
        where Model.RawInput == Preprocessor.EncodedInput
    
    // Model output must be compatible with the Labeler input
    associatedtype Labeler: ModelLabeler
        where Labeler.ModelOutput == Model.RawOutput,
              Labeler.PredictedLabels == PredictedLabels
    
    associatedtype PredictedLabels
    
    /**
     Preprocessor object, specific to the model, encoding an input string into a proper input format suitable for the internal model
     */
    var preprocessor: Preprocessor { get }
    
    /**
     Internal Machine Learning model, capable of processing raw input data
     */
    var model: Model { get }
    
    /**
     Object producing the labels predicted by the classifier, given the model raw output
     */
    var labeler: Labeler { get }
    
    /**
     Classify a text sample and provide the resulting prediction in an application-level format.
     - parameter text: A string containing the sample to be classified
     - returns: The prediction made by the classifier in a high level format
     */
    func classify(text: String) -> PredictedLabels
}

extension TextClassifier {
    /**
     Default implementation for the `classify(text:)` method
     */
    func classify(text: String) -> PredictedLabels {
        let t0 = Date()
        
        // preprocess input
        let encodedText = self.preprocessor.preprocess(text: text)
        
        let t_after_preprocessing = Date()
        let ms_after_preprocessing = 1000.0 * t_after_preprocessing.timeIntervalSince(t0)
        print("Preprocessing time: \(ms_after_preprocessing) ms")
        
        // process input data and produce the model raw output
        let modelOutput = self.model.execute(input: encodedText)
        
        let t_after_inference = Date()
        let ms_after_inference = 1000.0 * t_after_inference.timeIntervalSince(t_after_preprocessing)
        print("Inference time: \(ms_after_inference) ms")
        
        // assign labels from the model raw output
        let modelPrediction = self.labeler.predictLabels(from: modelOutput)
        
        let t_after_prediction = Date()
        let total_ms_for_classification = 1000.0 * t_after_prediction.timeIntervalSince(t0)
        print("Total classification time: \(total_ms_for_classification) ms")
        
        return modelPrediction
    }
}
