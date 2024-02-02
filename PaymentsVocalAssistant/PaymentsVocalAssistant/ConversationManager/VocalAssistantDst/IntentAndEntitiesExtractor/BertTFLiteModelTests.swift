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

    func testBertTFLiteModel() throws {
        let text = ExampleText.cic.text
        let dialogueManager = self.vocalAssistant.newConversation()
        let textClassifier = dialogueManager.intentAndEntitiesExtractor.intentAndEntitiesClassifier as! BertTextClassifier
        
        let classifierResult = textClassifier.classify(text: text)
        XCTAssert(classifierResult.isSuccess)
        
        let (classifierInput, classifierOutput) = classifierResult.success!
        
        let expectedIntentLabel = PaymentsIntentType.sendMoney.label
        XCTAssertEqual(classifierOutput.intentLabel, expectedIntentLabel)
        
        var expectedEntityLabels: [Int] = [
            PaymentsEntityType.defaultLabel,
            PaymentsEntityType.defaultLabel,
            PaymentsEntityType.defaultLabel,
            PaymentsEntityType.defaultLabel,
            PaymentsEntityType.defaultLabel,
            PaymentsEntityType.amount.beginLabel,
            PaymentsEntityType.amount.insideLabel,
            PaymentsEntityType.defaultLabel,
            PaymentsEntityType.user.beginLabel,
            PaymentsEntityType.user.insideLabel,
            PaymentsEntityType.user.insideLabel,
            PaymentsEntityType.defaultLabel,
        ]
        
        expectedEntityLabels += Array(
            repeating: PaymentsEntityType.defaultLabel,
            count: BertConfig.sequenceLength - expectedEntityLabels.count
        )
        
        XCTAssertEqual(classifierOutput.entitiesLabels, expectedEntityLabels)
    }
    
    func testTFLitePerformance() throws {
        let text = ExampleText._3.text
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

