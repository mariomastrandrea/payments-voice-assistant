//
//  Errors.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 19/01/24.
//

import Foundation

enum BertExtractorError: IntentAndEntitiesExtractorError {
    // BERT preprocessor
    case failedBertTokenization(text: String)
    
    // TF Lite model
    case tfLiteModelFailedInput(why: String)
    case tfLiteModelFailedInference(why: String)
    case tfLiteModelFailedOutput(why: String)
    
    var description: String {
        switch self {
        case .failedBertTokenization(let text):
            return "Failed BERT tokenization of text: \"\(text)\""
        case .tfLiteModelFailedInput(let why):
            return "Failed to copy input data into TF Lite interpreter. Error: \(why)"
        case .tfLiteModelFailedInference(let why):
            return "Failed inference on TF Lite interpreter. Error: \(why)"
        case .tfLiteModelFailedOutput(let why):
            return "Failed to retrieve output Tensors from TF Lite interpreter. Error: \(why)"
        }
    }
}

typealias BertExtractorResult<T> = Result<T, BertExtractorError>

