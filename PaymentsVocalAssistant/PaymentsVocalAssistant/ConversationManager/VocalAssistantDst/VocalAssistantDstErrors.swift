//
//  ExtractorError.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 19/01/24.
//

import Foundation

// intent and entities extractor

protocol IntentAndEntitiesExtractorError: Error {
    var description: String { get }
}

extension Result where Failure: IntentAndEntitiesExtractorError {
    func toAssistantDialogueManagerResult() -> Result<Success, VocalAssistantDstError>! {
        switch self {
        case .success(let content): return .success(content)
        case .failure(let error): return .failure(.extractorError(error: error))
        }
    }
}

// assistant dialogue manager

enum VocalAssistantDstError: Error {
    case extractorError(error: any IntentAndEntitiesExtractorError)
    
    var message: String {
        switch self {
        case .extractorError(let error): return error.description
        }
    }
}

typealias VocalAssistantDstResult<T> = Result<T, VocalAssistantDstError>


