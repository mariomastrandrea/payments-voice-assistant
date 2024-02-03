//
//  CustomLMtests.swift
//  PaymentsVocalAssistantTests
//
//  Created by Mario Mastrandrea on 03/02/24.
//

import XCTest
import Contacts
@testable import PaymentsVocalAssistant

final class CustomLMtests: XCTestCase {
    private let contactStore: CNContactStore = CNContactStore()
    private var contacts: [VocalAssistantContact] = []
    private var appContext: AppContext!
    
    override func setUpWithError() throws {
        self.appContext = AppContext(
            userContacts: [AppDelegateStub.antonioRossiContact, AppDelegateStub.giuseppeVerdiContact],
            userBankAccounts: [AppDelegateStub.futureBankAccount, AppDelegateStub.topBankAccount]
        )
    }

    func testCustomLMcreationAndExport() async throws {
        let contacts = await fetchContacts(contactStore: self.contactStore)
        XCTAssertNotNil(contacts)
        guard let contacts = contacts else { return }
        
        let limitedNumOfContacts = Int(Double(contacts.count) * 0.025)
        let limitedContacts = Array(contacts.prefix(upTo: limitedNumOfContacts))
        print("limitedNumOfContacts: \(limitedContacts.count)")
        
        let speechRecognizer = await SpeechRecognizer()
        XCTAssertNotNil(speechRecognizer)
        guard let speechRecognizer = speechRecognizer else { return }
        
        await speechRecognizer.createCustomLM(
            names: self.appContext.userContacts.compactMap { $0.firstName.isEmpty ? nil : $0.firstName },
            surnames: self.appContext.userContacts.compactMap { $0.lastName.isEmpty ? nil : $0.lastName },
            banks: self.appContext.userBankAccounts.map { $0.name }
        )

    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

