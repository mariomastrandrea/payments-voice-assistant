//
//  Tokenizer.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 16/01/24.
//

import Foundation

/**
 A generic object to split a text into tokens. It might be used from a `TextPreprocessor` for the data preprocessing stage.
 */
protocol Tokenizer {
    /**
        Split a text string in an array of tokens
     */
    func tokenize(_ text: String) -> [String]
    
    /**
        Convert string tokens into the corresponding numeric IDs
     */
    func convertToIDs(tokens: [String]) -> [Int32]
}