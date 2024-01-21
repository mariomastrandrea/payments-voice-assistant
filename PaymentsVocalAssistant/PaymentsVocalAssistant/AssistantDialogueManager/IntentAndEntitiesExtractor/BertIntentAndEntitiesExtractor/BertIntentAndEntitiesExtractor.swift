//
//  BertIntentAndEntitiesExtractor.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 18/01/24.
//

import Foundation

/**
 Object performing both Intent classification and Entity extraction tasks for the Payements Vocal assistant, leveraging a BERT-based Machine Learning model
 */
class BertIntentAndEntitiesExtractor: IntentAndEntitiesExtractor {
    typealias Classifier = BertTextClassifier
    typealias CustomError = BertExtractorError
    
    var intentAndEntitiesClassifier: BertTextClassifier
    
    init(classifier: BertTextClassifier) {
        self.intentAndEntitiesClassifier = classifier
    }

    func recognize(from transcript: String) -> BertExtractorResult<IntentAndEntitiesPrediction> {
        // TODO: implement method (retrieve labels and map them to actual types, extract entities)
        exit(1)
    }
}
