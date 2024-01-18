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
    /**
     Classify the intent and extract relevant entities from the user's speech
     - parameter userSpeech: transcript of the user's speech
     */
    func recognize(from userSpeech: String) -> IntentAndEntitiesResult
}
