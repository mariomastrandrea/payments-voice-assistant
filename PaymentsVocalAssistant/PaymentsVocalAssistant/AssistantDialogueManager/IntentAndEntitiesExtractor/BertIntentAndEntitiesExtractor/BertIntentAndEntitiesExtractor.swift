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
    
    var intentAndEntitiesClassifier: BertTextClassifier
    
    init(classifier: BertTextClassifier) {
        self.intentAndEntitiesClassifier = classifier
    }

    func recognize(from transcript: String) -> BertExtractorResult<IntentAndEntitiesPrediction> {
        // TODO: implement method (retrieve labels and map them to actual types, extract entities)
        let classifierPredictionResult = self.intentAndEntitiesClassifier.classify(text: transcript)
        
        guard let (classifierInput, classifierOutput) = classifierPredictionResult.success else {
            return classifierPredictionResult.failureResult()
        }
        
        // 1. extract intent
        guard let intent = PaymentsIntent(
            label: classifierOutput.intentLabel,
            probability: classifierOutput.intentProbability
        ) else {
            return .failure(.intentLabelNotValid(intentLabel: classifierOutput.intentLabel))
        }
        
        // 2. extract entities
        var entities = [PaymentsEntity]()
        
        // keep just the original number of tokens info
        let numRelevantTokens = classifierInput.sentenceTokens.count
        let entitiesLabels = classifierOutput.entitiesLabels
        let entitiesProbabilities = classifierOutput.entitiesProbabilities
        
        var i = 0
        while i < numRelevantTokens {
            let label = entitiesLabels[i]
            
            // check label range correctness
            guard let entityType = PaymentsEntityType.of(label) else {
                return .failure(.entityLabelNotValid(entityLabel: label))
            }
            
            if PaymentsEntity.isBioBegin(label: label) {
                // this is the start of a new entity
                var tokens: [String] = [classifierInput.sentenceTokens[i]]
                var tokensLabels: [Int] = [label]
                var labelsProbabilities: [Float32] = [entitiesProbabilities[i]]
                    
                i += 1
                while PaymentsEntity.isBioInside(label: entitiesLabels[i], withRespectTo: entityType) {
                    tokens.append(classifierInput.sentenceTokens[i])
                    tokensLabels.append(entitiesLabels[i])
                    labelsProbabilities.append(entitiesProbabilities[i])
                    i += 1
                }
                i -= 1
                
                // extracted entity
                let extractedEntity = PaymentsEntity(
                    type: entityType,
                    tokens: tokens,
                    tokensLabels: tokensLabels,
                    tokensLabelsProbabilities: labelsProbabilities
                )
                
                entities.append(extractedEntity)
            }
            
            i += 1
        }
        
        return .success(
            IntentAndEntitiesPrediction(
                sentence: transcript,
                sentenceTokens: classifierInput.sentenceTokens,
                predictedIntent: intent,
                predictedEntities: entities
            )
        )
    }
}
