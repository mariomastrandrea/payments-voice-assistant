//
//  MachineLearningModel.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 17/01/24.
//

import Foundation

/**
 A generic machine learning model, having a specific input and a specific output formats
 */
protocol MachineLearningModel {
    associatedtype RawInput
    associatedtype RawOutput
    
    /**
     Perform an inference providing a raw input to the model
     - parameter input: Raw input specific to the model
     - returns: Raw output provided by the internal model
     */
    func execute(input: RawInput) -> RawOutput
}
