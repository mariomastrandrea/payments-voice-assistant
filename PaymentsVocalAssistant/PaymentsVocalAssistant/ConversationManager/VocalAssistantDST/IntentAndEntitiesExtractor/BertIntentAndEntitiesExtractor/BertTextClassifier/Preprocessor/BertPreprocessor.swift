//
//  BertTextPreprocessor.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 16/01/24.
//

import Foundation

/**
 Text preprocessor for a BERT encoder
 */
class BertPreprocessor: TextPreprocessor {
    typealias EncodedInput = BertInput
    typealias PreprocessorError = BertExtractorError
    
    // properties
    private var tokenizer: BertTokenizer
    
    init(tokenizer: BertTokenizer) {
        self.tokenizer = tokenizer
    }
    
    /**
     Preprocess an input text to make it suitable for a BERT encoder
     
     - parameter text: the input text to be preprocessed
     - returns: An object enclosing the three input embeddings (token ids, type ids, attention mask) for a BERT model
     */
    func preprocess(text: String) -> BertExtractorResult<BertInput> {
        // * 1. produce the string tokens using the BERT tokenizer *
        var inputTokens = self.tokenizer.tokenize(text)
        
        if !text.isEmpty && inputTokens.isEmpty {
            return .failure(.failedBertTokenization(text: text))
        }
        
        // drop any additional token, keeping just the first 'maxNumTokens'
        // number of tokens (2 are for the special tokens)
        inputTokens = Array(inputTokens.prefix(BertConfig.sequenceLength - 2))
        
        // * 2. add special tokens at the beginning and at the end *
        inputTokens.insert(BertConfig.startOfSequenceToken, at: 0)
        inputTokens.append(BertConfig.sentenceSeparatorToken)
        
        // * 3. create type ids, input ids and attention mask *
        
        let typeIds = [Int32](repeating: 0, count: BertConfig.sequenceLength)
        
        // convert to numerical IDs
        var tokenIds = self.tokenizer.convertToIDs(tokens: inputTokens)
        // create attention mask
        var attentionMask = [Int32](repeating: 1, count: tokenIds.count)
        
        // add padding up to max length
        let paddingLength = BertConfig.sequenceLength - tokenIds.count
        tokenIds.append(contentsOf: [Int32](repeating: 0, count: paddingLength))
        attentionMask.append(contentsOf: [Int32](repeating: 0, count: paddingLength))
                
        return .success(
            BertInput(
                sentenceTokens: inputTokens,
                inputWordIds: tokenIds,
                inputTypeIds: typeIds,
                inputMask: attentionMask
            )
        )
    }
}
