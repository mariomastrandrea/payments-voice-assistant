//
//  IntentRecognizerEntityExtractor.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 17/01/24.
//

import Foundation

protocol IntentAndEntitiesClassifier: TextClassifier
    where PredictedLabels == IntentAndEntitiesLabels {}
