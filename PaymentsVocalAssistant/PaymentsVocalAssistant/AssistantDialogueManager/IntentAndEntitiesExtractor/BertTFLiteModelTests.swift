//
//  TFLiteModelTests.swift
//  PaymentsVocalAssistantTests
//
//  Created by Mario Mastrandrea on 21/01/24.
//

import XCTest
@testable import PaymentsVocalAssistant

final class BertTFLiteModelTests: XCTestCase {
    var preprocessor: BertPreprocessor!
    var classifier: BertTFLiteIntentAndEntitiesClassifier!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.preprocessor = BertPreprocessor.instance
        self.classifier = BertTFLiteIntentAndEntitiesClassifier.instance
    }

    func testExample() throws {
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let text = "I want to send $23.5 to Pier"
        
        let preprocessingOutput = self.preprocessor.preprocess(text: text)
        XCTAssert(preprocessingOutput.isSuccess, "failed preprocessing")
        
        let encodedText = preprocessingOutput.success!
        
        let inferenceOutput = self.classifier.execute(input: encodedText)
        XCTAssert(inferenceOutput.isSuccess, "failed inference")
        
        let inferenceOutputProbabilities = inferenceOutput.success!
        
        print(inferenceOutputProbabilities)
    }

    

}

