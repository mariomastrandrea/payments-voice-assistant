//
//  PaymentsAssistantTextClassifier.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 17/01/24.
//

import Foundation

class PaymentsAssistantTextClassifier {
    private let textClassifier: any IntentAndEntitiesClassifier
    
    init(textClassifier: any IntentAndEntitiesClassifier) {
        self.textClassifier = textClassifier
    }
    
    func recognizeIntentAndExtractEntities(from userSpeech: String) {
        let a = self.textClassifier.classify(text: <#T##String#>)
        print(a)
    }
}
