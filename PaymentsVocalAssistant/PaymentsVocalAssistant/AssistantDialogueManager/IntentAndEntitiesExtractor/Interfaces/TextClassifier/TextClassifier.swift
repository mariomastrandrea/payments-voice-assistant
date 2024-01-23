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
protocol TextClassifier<TextClassifierError> {
    associatedtype Preprocessor: TextPreprocessor
    
    // Preprocessor output must be compatible with the Model input
    associatedtype Model: MachineLearningModel
        where Model.RawInput == Preprocessor.EncodedInput
    
    // Model output must be compatible with the Labeler input
    associatedtype Labeler: ModelLabeler
        where Labeler.ModelOutput == Model.RawOutput,
              Labeler.PredictedLabels == PredictedLabels
    
    associatedtype PredictedLabels
    
    // the Error type must be the same across all the classifier components
    associatedtype TextClassifierError where TextClassifierError: Error,
              TextClassifierError == Preprocessor.PreprocessorError,
              TextClassifierError == Model.ModelError,
              TextClassifierError == Labeler.LabelerError
    
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
     - returns: The encoded input and the prediction made by the classifier in a high level format
     */
    func classify(text: String) -> Result<
        (input: Preprocessor.EncodedInput, output: PredictedLabels),
        TextClassifierError
    >
}
