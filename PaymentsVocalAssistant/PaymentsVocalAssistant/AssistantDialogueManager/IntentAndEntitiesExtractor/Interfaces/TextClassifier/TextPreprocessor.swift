//
//  Preprocessor.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 16/01/24.
//

import Foundation

/**
 A generic object to preprocess text and convert it in a proper format for a `TextClassifier` model
 */
protocol TextPreprocessor<PreprocessorError> {
    associatedtype EncodedInput
    associatedtype PreprocessorError: Error
    
    /**
     Preprocess an input text transforming it into a proper format suitable for the model
     - parameter text: the input text string
     - returns: a model-specific object containing the properly formatted input
     */
    func preprocess(text: String) -> Result<EncodedInput, PreprocessorError>
}
