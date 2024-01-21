//
//  EntityIntentLabeler.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 17/01/24.
//

import Foundation

class IntentEntityLabeler: ModelLabeler {
    typealias ModelOutput = IntentsAndEntitiesProbabilities
    typealias PredictedLabels = IntentAndEntitiesRawLabels
    typealias LabelerError = BertExtractorError
    
    /**
     Predict intent labels and entity labels based on the probabilities predicted by the BERT classifier and on the thresholds defined in the config
     - parameter probabilities: an object enclosing the intent probabilities and the entities probabilities predicted by the classifier
     - returns: an object enclosing the assigned labels for both tasks: one label for the intent and one entity label for each sentence token
     */
    func predictLabels(
        from probabilities: IntentsAndEntitiesProbabilities
    ) -> BertExtractorResult<IntentAndEntitiesRawLabels> {
        // use thresholds and assign numeric labels
        
        // 1. map intents probabilities to the intent label
        let (predictedIntentLabel, predictedIntentProbability) = mapToLabels(
            outputProbabilities: probabilities.intentRecognitionOutput,
            threshold: BertConfig.intentClassificationProbabilityThreshold,
            defaultLabel: VocalAssistantConfig.defaultIntentLabel
        )
         
        // 2. map entities probabilities to labels
        var predictedEntitiesLabels = [Int]()
        var predictedEntitiesProbabilities = [Float32]()
        
        for tokenEntitiesProbabilities in probabilities.entityExtractionOutput {
            let (tokenPredictedEntityLabel, tokenPredictedEntityProbability) = mapToLabels(
                outputProbabilities: tokenEntitiesProbabilities,
                threshold: BertConfig.entityClassificationProbabilityThreshold,
                defaultLabel: VocalAssistantConfig.defaultEntityLabel
            )
            
            predictedEntitiesLabels.append(tokenPredictedEntityLabel)
            predictedEntitiesProbabilities.append(tokenPredictedEntityProbability)
        }
        
        return .success(
            IntentAndEntitiesRawLabels(
                intentLabel: predictedIntentLabel,
                intentProbability: predictedIntentProbability,
                entitiesLabels: predictedEntitiesLabels,
                entitiesProbabilities: predictedEntitiesProbabilities
            )
        )
    }
    
    private func mapToLabels(
        outputProbabilities: [Float32],
        threshold: Float32,
        defaultLabel: Int
    ) -> (label: Int, probability: Float32) {
        var predictedLabel = outputProbabilities.argMax()!
        var predictedLabelProbability = outputProbabilities[predictedLabel]
        
        // if the predicted label has a probability lower than the threshold, fall back to the default label
        if predictedLabelProbability < threshold {
            predictedLabel = 0
            predictedLabelProbability = outputProbabilities[0]
        }
        
        return (
            label: predictedLabel,
            probability: predictedLabelProbability
        )
    }
}
