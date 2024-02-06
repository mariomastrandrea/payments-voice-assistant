//
//  TestAppMainView.swift
//  PaymentsVocalAssistant_testApp
//
//  Created by Mario Mastrandrea on 05/02/24.
//

import SwiftUI
import Contacts

struct TestAppMainView: View {
    private static let title = "Hi there! 🚀"
    private static let buttonLabel = "Start"
    
    private static let greetingsDescription = """
    My name is Mario Mastrandrea and this is the test app for my Master's Thesis 🎓 in:
       "Developing an AI-Powered Voice Assistant for an iOS Mobile Payment App"
    
    Thank you for joining this test! 🙏🏻
    """
    
    private static let contextDescription = """
    ✅  Test the performance of my Voice Assistant, which will then be integrated into an  application involving P2P payments 📲
    
    ✅  You are a registered user with the two (fake) bank accounts at "Top Bank" and "Future Bank" 🏦
    """
    
    private static let assistantDescription = """
    ✅  My Voice Assistant can help you perform the following tasks:
        💸  send money to another user
        💰  request money from another user
        📈  check a bank account's balance
        💳  check the last transactions (eventually involving a specific user or bank account)
    
    ✅  The assistant works *entirely* on your device, from voice recognition to answer generation, without sending any data over the network (isn't that great?) ‼️
    """
    
    private static let formDescription = """
    ✅  It is not perfect (not yet!), so once you are done with your tests, please fill out this form to leave your feedbacks: they will be a fundamental part of my Thesis work 📊
    """
    
    private static let vocalAssistantWrapperDescription = """
    ✅  Let's try it!
    """
        
    private static let formUrl = "https://forms.gle/EVn8UkvKaEVwHADo6"
    private static let formLabel = "Go to form"
    private static let descriptionFontSize = 18.5
    
    let contactStore: CNContactStore
    
    init() {
        self.contactStore = CNContactStore()
        
        UIPageControl.appearance().currentPageIndicatorTintColor = .label
                UIPageControl.appearance().pageIndicatorTintColor = UIColor.label.withAlphaComponent(0.2)
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 5) {
                Text(TestAppMainView.title)
                    .bold()
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                                
                VStack {
                    TabView {
                        TestAppGreetingsView(
                            text: TestAppMainView.greetingsDescription,
                            size: TestAppMainView.descriptionFontSize
                        )
                        TestAppContextDescriptionView(
                            text: TestAppMainView.contextDescription,
                            size: TestAppMainView.descriptionFontSize
                        )
                        TestAppAssistantDescriptionView(
                            text: TestAppMainView.assistantDescription,
                            size: TestAppMainView.descriptionFontSize
                        )
                        TestAppFormView(
                            text: TestAppMainView.formDescription,
                            size: TestAppMainView.descriptionFontSize,
                            formUrl: TestAppMainView.formUrl,
                            formLabel: TestAppMainView.formLabel
                        )
                        TestAppVocalAssistantWrapperView(
                            text: TestAppMainView.vocalAssistantWrapperDescription,
                            size: TestAppMainView.descriptionFontSize,
                            buttonLabel: TestAppMainView.buttonLabel,
                            labelSize: TestAppMainView.descriptionFontSize,
                            contactStore: self.contactStore
                        )
                    }
                    .tabViewStyle(.page(indexDisplayMode: .automatic)) // Makes the TabView swipeable
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                // .background(Color.gray)
                .padding(.vertical, 35)
                .cornerRadius(30)
            }
            .padding(.horizontal, 35)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Menu")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}



#Preview {
    TestAppMainView()
}

