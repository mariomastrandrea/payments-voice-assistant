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
    
    // properties
    var intentAndEntitiesClassifier: BertTextClassifier
    
    init(classifier: BertTextClassifier) {
        self.intentAndEntitiesClassifier = classifier
    }

    /**
     Predict intent and entities, map labels to actual types and extract all their high level information
     */
    func recognize(from transcript: String) -> AssistantDialogueManagerResult<IntentAndEntitiesPrediction> {
        // perform raw classification
        let classifierPredictionResult = self.intentAndEntitiesClassifier.classify(text: transcript)
        
        guard let (classifierInput, classifierOutput) = classifierPredictionResult.success else {
            return classifierPredictionResult.failureResult().toAssistantDialogueManagerResult()
        }
        
        // 1. extract intent
        guard let intent = PaymentsIntent(
            label: classifierOutput.intentLabel,
            probability: classifierOutput.intentProbability
        ) 
        else {
            return .failure(
                .extractorError(
                    error: BertExtractorError.intentLabelNotValid(intentLabel: classifierOutput.intentLabel)
                )
            )
        }
        
        // 2. extract entities
        var entities = [PaymentsEntity]()
        
        // consider just the original number of tokens info (exclude the padding)
        let numRelevantTokens = classifierInput.sentenceTokens.count  // (it includes [CLS] and [SEP])
        let entitiesLabels = classifierOutput.entitiesLabels
        let entitiesProbabilities = classifierOutput.entitiesProbabilities
        
        var i = 0
        while i < numRelevantTokens {
            let label = entitiesLabels[i]
            
            // check label range correctness
            guard PaymentsEntity.isValid(label: label) else {
                return .failure(
                    .extractorError(
                        error: BertExtractorError.entityLabelNotValid(entityLabel: label)
                    )
                )
            }
            
            if PaymentsEntity.isBioBegin(label: label) {
                let entityType = PaymentsEntityType.of(label)!

                // this is the start of a new entity
                var entityTokens: [String] = [classifierInput.sentenceTokens[i]]
                var entityLabels: [Int] = [label]
                var entityLabelsProbabilities: [Float32] = [entitiesProbabilities[i]]
                    
                // add any eventual Inside token of the same entity
                i += 1
                while PaymentsEntity.isBioInside(label: entitiesLabels[i], withRespectTo: entityType) {
                    entityTokens.append(classifierInput.sentenceTokens[i])
                    entityLabels.append(entitiesLabels[i])
                    entityLabelsProbabilities.append(entitiesProbabilities[i])
                    i += 1
                }
                i -= 1
                
                // compute entity global probability and check it is above the threshold, otherwise do not add it
                let globalEntityProbability = entityLabelsProbabilities.reduce(Float32(1.0), *)
                
                if globalEntityProbability >= BertConfig.entityGlobalProbabilityThreshold {
                    let reconstructedTokens = self.reconstruct(subtokens: entityTokens)
                    let reconstructedEntityString = self.reconstruct(entity: entityType, fromReconstructedTokens: reconstructedTokens)
                    
                    // save extracted entity
                    let extractedEntity = PaymentsEntity(
                        type: entityType,
                        reconstructedEntity: reconstructedEntityString,
                        entityProbability: globalEntityProbability,
                        reconstructedTokens: reconstructedTokens,
                        rawTokens: entityTokens,
                        tokensLabels: entityLabels,
                        tokensLabelsProbabilities: entityLabelsProbabilities
                    )
                    
                    entities.append(extractedEntity)
                }
            }
            
            i += 1
        }
        
        return .success(
            IntentAndEntitiesPrediction(
                predictedIntent: intent,
                predictedEntities: entities
            )
        )
    }
    
    /**
     Reconstruct subtokens (if any) into entire tokens. In this way, all the words represent a single tokens (no word is split in subtokens)
     */
    private func reconstruct(subtokens: [String]) -> [String] {
        var reconstructedTokens = [String]()
        var lastToken = ""
        
        for (i, token) in subtokens.enumerated() {
            if i > 0 && token.starts(with: BertConfig.subtokenIdentifier) {
                
                lastToken += token.removeLeading(BertConfig.subtokenIdentifier)
            }
            else {
                if lastToken.isNotEmpty {
                    reconstructedTokens.append(lastToken)
                }
                lastToken = token
            }
        }
        
        reconstructedTokens.append(lastToken)
        return reconstructedTokens
    }
    
    /**
     Reconstruct the original entity String from its tokens
     */
    private func reconstruct(entity entityType: PaymentsEntityType, fromReconstructedTokens tokens: [String]) -> String {
        var reconstructedEntityTokens = tokens
        let punctuationRegex = "^[\(BertConfig.punctuationSymbolsToJoin.joined())]$"

        var i = 0
        while i < reconstructedEntityTokens.count {
            let token = reconstructedEntityTokens[i]
            
            if token.matches(punctuationRegex) {
                // join punctuation tokens with adjacent tokens
                var joinedAdjacentTokens = token
                
                if i-1 >= 0 {
                    let previousToken = reconstructedEntityTokens.remove(at: i-1)
                    i -= 1    // re-align index
                    joinedAdjacentTokens.insert(contentsOf: previousToken, at: joinedAdjacentTokens.startIndex)
                }
                
                if i+1 < reconstructedEntityTokens.count {
                    let nextToken = reconstructedEntityTokens.remove(at: i+1)
                    joinedAdjacentTokens.append(nextToken)
                }
                
                // override old token with the new one
                reconstructedEntityTokens[i] = joinedAdjacentTokens
            }
            
            i += 1
        }
        
        let reconstructedEntity = reconstructedEntityTokens.joined(separator: " ")
        return reconstructedEntity
    }
}
