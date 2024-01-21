//
//  ExtractorError.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 19/01/24.
//

import Foundation

protocol IntentAndEntitiesExtractorError: Error { 
    var description: String { get }
}

