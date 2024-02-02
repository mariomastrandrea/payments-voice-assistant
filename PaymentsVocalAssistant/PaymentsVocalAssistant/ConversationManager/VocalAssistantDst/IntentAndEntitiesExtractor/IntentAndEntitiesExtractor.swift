//
//  IntentAndEntitiesExtractor.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 18/01/24.
//

import Foundation



/**
 A generic interface for an object extracting the intent and its relevant entities from a transcript
 */
protocol IntentAndEntitiesExtractor {
    // the Classifier error must comply to the `IntentAndEntitiesExtractorError`
    associatedtype Classifier : IntentAndEntitiesClassifier
        where Classifier.TextClassifierError : IntentAndEntitiesExtractorError
    
    /**
     Underlying ML classifier object to predict intent and entities labels
     */
    var intentAndEntitiesClassifier: Classifier { get }
    
    /**
     Classify the intent and extract relevant entities from the user's speech
     - parameter userSpeech: transcript of the user's speech
     */
    func recognize(from userSpeech: String) -> VocalAssistantDstResult<IntentAndEntitiesPrediction>
}



