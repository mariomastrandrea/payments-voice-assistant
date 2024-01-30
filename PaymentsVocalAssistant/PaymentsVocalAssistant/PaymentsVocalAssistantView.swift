//
//  PaymentsVocalAssistantView.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 29/01/24.
//

import SwiftUI

public struct PaymentsVocalAssistantView: View {
    private let config: VocalAssistantCustomConfig

    // View state
    @State private var conversationManager: ConversationManager!
    @State private var assistantAnswer: String
    @State private var isAssistantInitialized: Bool
    
    // app state
    private let userContacts: [VocalAssistantContact]
    private let userBankAccounts: [VocalAssistantBankAccount]
    
    private var isEntirePaymentsVocalAssistantInitialized: Bool {
        // TODO: add also speech recognizer init and TTS init flags
        return self.isAssistantInitialized
    }

    public init(
        userContacts: [VocalAssistantContact],
        userBankAccounts: [VocalAssistantBankAccount],
        config: VocalAssistantCustomConfig = VocalAssistantCustomConfig()
    ) {
        self.userContacts = userContacts
        self.userBankAccounts = userBankAccounts
        
        self.config = config
        self.assistantAnswer = "Hi this is a custom text example to test the functionality of the typewriter text component, cause I guess it does not work properly. Just kidding"
        
        // TODO: set to true only after vocal assistant successful initialization
        self.isAssistantInitialized = false
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            VocalAssistantTitle(
                self.config.title,
                color: self.config.titleTextColor
            ).onAppear {
                self.initializeVocalAssistant()
            }
            
            if !self.isAssistantInitialized {
                VocalAssistantActivityIndicator()
            }
            else {
                VocalAssistantAnswerBox(
                    assistantAnswer: self.assistantAnswer,
                    textColor: self.config.assistantAnswerBoxTextColor,
                    boxBackground: self.config.assistantAnswerBoxBackground
                )
            }
                    
            Spacer()
            
            // button to record user's speech
            VocalAssistantRecButton(
                disabled: !self.isEntirePaymentsVocalAssistantInitialized,
                imageName: self.config.recButtonImageName,
                text: self.config.recButtonText,
                textColor: self.config.recButtonForegroundColor,
                fillColor: self.config.recButtonFillColor
            ) {
                self.captureSpeech()
            }
        }
        .padding(.bottom, 20)
        .background(self.config.backgroundColor)
    }
    
    private func initializeVocalAssistant() {
        Task { @MainActor in
            // instantiate the PaymentsVocalAssistant
            guard let vocalAssistant = await PaymentsVocalAssistant.instance(
                userContacts: self.userContacts,
                userBankAccounts: self.userBankAccounts
            ) else {
                // initialization error occurred
                Task { @MainActor in
                    // show error
                    self.assistantAnswer = self.config.initializationErrorMessage
                    logError("PaymentsVocalAssistant is nil after getting singleton instance")
                }
                return
            }
            
            logSuccess("vocal assistant initialized")
            self.isAssistantInitialized = true
            self.conversationManager = vocalAssistant.newConversation()
        }
    }
    
    private func captureSpeech() {
        // Simulate an assistant's response
        self.assistantAnswer = "I'm good, thank you for asking!"
    }
}

#Preview {
    PaymentsVocalAssistantView(
        userContacts: [],
        userBankAccounts: []
    )
}
