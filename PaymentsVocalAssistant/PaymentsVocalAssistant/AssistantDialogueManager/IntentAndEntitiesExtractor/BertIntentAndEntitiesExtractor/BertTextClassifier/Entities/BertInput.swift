//
//  BertInput.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 17/01/24.
//

import Foundation

/**
 An object enclosing a raw input for a BERT model: input_word_ids, input_type_ids and input_mask
 */
struct BertInput {
    let sentenceTokens: [String]
    let inputWordIds: [Int32]      // tokens' numeric IDs
    let inputTypeIds: [Int32]      // specify which sentence a token belongs to
    let inputMask: [Int32]         // attention mask
}
