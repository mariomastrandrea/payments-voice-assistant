//
//  BertTextClassifierModel.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 16/01/24.
//

import Foundation

class BertTextClassifier: IntentAndEntitiesClassifier {
    typealias Preprocessor = BertPreprocessor
    typealias Model = BertTFLiteIntentClassifierEntityExtractor
    typealias Labeler = IntentEntityLabeler

    var preprocessor: BertPreprocessor
    var model: BertTFLiteIntentClassifierEntityExtractor
    var labeler: IntentEntityLabeler
    
    init(
        preprocessor: BertPreprocessor,
        model: BertTFLiteIntentClassifierEntityExtractor,
        labeler: IntentEntityLabeler
    ) {
        self.preprocessor = preprocessor
        self.model = model
        self.labeler = labeler
    }
}
