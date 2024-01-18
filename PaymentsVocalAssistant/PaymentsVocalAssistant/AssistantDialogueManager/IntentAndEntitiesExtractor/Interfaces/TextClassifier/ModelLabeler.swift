//
//  Labeler.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 17/01/24.
//

import Foundation

/**
 A generic object which assigns labels given a Machine Learning model's raw prediction
 */
protocol ModelLabeler {
    associatedtype ModelOutput
    associatedtype PredictedLabels
    
    /**
     Predict the labels of an input sample, given the raw probabilities produced by a Machine Learning model
     - parameter probabilities: an object containing the raw probabilities produced by a model inference
     - returns: an object containing the predicted labels
     */
    func predictLabels(from probabilities: ModelOutput) -> PredictedLabels
}
