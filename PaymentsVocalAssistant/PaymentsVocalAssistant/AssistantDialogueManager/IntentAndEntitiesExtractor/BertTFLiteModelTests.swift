//
//  TFLiteModelTests.swift
//  PaymentsVocalAssistantTests
//
//  Created by Mario Mastrandrea on 21/01/24.
//

import XCTest
@testable import PaymentsVocalAssistant

final class BertTFLiteModelTests: XCTestCase {
    var originalLogFlagValue: Bool!
    let text1 = "I need the transaction history involving Ylenia Leone"
    let text2 = "I am instructing a collection of $412.90 from sister-in-law Marta through my CaixaBank"
    var vocalAssistant: PaymentsVocalAssistant!
    
    override func setUpWithError() throws {
        // disable flag
        self.originalLogFlagValue = GlobalConfig.enableLogs
        GlobalConfig.enableLogs = false
        
        let vocalAssistant = PaymentsVocalAssistant(type: .bert)
        XCTAssertNotNil(vocalAssistant, "Failed to initialize PaymentsVocalAssistant")
        self.vocalAssistant = vocalAssistant!
    }
    
    override func tearDownWithError() throws {
        // reset flag
        GlobalConfig.enableLogs = self.originalLogFlagValue
    }

    func testExtractedIntentAndEntities() throws {
        let text = "I want to send 47 cents to Andrea Cic"
        let dialogueManager = self.vocalAssistant.newConversation()

        let intentAndEntitiesExtractor = dialogueManager.intentAndEntitiesExtractor
        let recognitionOutput = intentAndEntitiesExtractor.recognize(from: text)
        XCTAssert(recognitionOutput.isSuccess)
        
        let prediction = recognitionOutput.success!
        
        print("\"\(text)\"\n")
        print(prediction.predictedIntent)
        print()
        
        for entity in prediction.predictedEntities {
            print(entity)
        }
    }
    
    func testTFLitePerformance() throws {
        let text = "Please arrange a payment of AED419 and 14 cents to Rodolfo"
        let dialogueManager = self.vocalAssistant.newConversation()
        let textClassifier = dialogueManager.intentAndEntitiesExtractor.intentAndEntitiesClassifier as! BertTextClassifier
        
        let preprocessor = textClassifier.preprocessor
        let tfLiteClassifier = textClassifier.model
        
        let preprocessingOutput = preprocessor.preprocess(text: text)
        XCTAssert(preprocessingOutput.isSuccess, "failed preprocessing")
        
        let encodedText = preprocessingOutput.success!
        
        self.measure {
            let inferenceOutput = tfLiteClassifier.execute(input: encodedText)
            XCTAssert(inferenceOutput.isSuccess, "failed inference")
        }
    }
}

