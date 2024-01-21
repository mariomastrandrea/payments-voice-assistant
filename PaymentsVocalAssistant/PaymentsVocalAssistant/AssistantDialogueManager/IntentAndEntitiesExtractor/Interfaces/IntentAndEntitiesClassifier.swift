//
//  IntentRecognizerEntityExtractor.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 17/01/24.
//

import Foundation

/**
 A generic interface for a Text Classifier specialized in prediction of Intents and Named Entities
 */
protocol IntentAndEntitiesClassifier: TextClassifier
    where PredictedLabels == IntentAndEntitiesRawLabels {  }
