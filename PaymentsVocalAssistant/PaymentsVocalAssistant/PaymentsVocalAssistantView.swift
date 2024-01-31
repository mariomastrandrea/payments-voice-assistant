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
    @State private var assistantAnswerText: String
    @State private var isAssistantInitialized: Bool = false
    
    // app state
    private let userContacts: [VocalAssistantContact]
    private let userBankAccounts: [VocalAssistantBankAccount]
    

    public init(
        userContacts: [VocalAssistantContact],
        userBankAccounts: [VocalAssistantBankAccount],
        config: VocalAssistantCustomConfig = VocalAssistantCustomConfig()
    ) {
        self.userContacts = userContacts
        self.userBankAccounts = userBankAccounts
        
        self.config = config
        self.isAssistantInitialized = false
        self.assistantAnswerText = ""
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            VocalAssistantTitle(
                self.config.title,
                color: self.config.titleTextColor
            ).onAppear {
                if !self.isAssistantInitialized {
                    self.initializeVocalAssistant()
                }
            }
            
            if !self.isAssistantInitialized {
                VocalAssistantActivityIndicator()
            }
            else {
                VocalAssistantAnswerBox(
                    assistantAnswer: self.assistantAnswerText,
                    textColor: self.config.assistantAnswerBoxTextColor,
                    boxBackground: self.config.assistantAnswerBoxBackground
                )
            }
                    
            Spacer()
            
            // button to record user's speech
            VocalAssistantRecButton(
                disabled: !self.isAssistantInitialized,
                imageName: self.config.recButtonImageName,
                text: self.config.recButtonText,
                textColor: self.config.recButtonForegroundColor,
                fillColor: self.config.recButtonFillColor,
                longPressStartAction: {
                    self.conversationManager.startListening()
                },
                longPressEndAction: {
                    let assistantResponse = self.conversationManager.processAndPlayResponse()
                    
                    self.assistantAnswerText = assistantResponse.textAnswer
                }
            )
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
            ) 
            else {
                // initialization error occurred
                self.assistantAnswerText = self.config.initializationErrorMessage
                
                logError("PaymentsVocalAssistant is nil after getting singleton instance")
                self.isAssistantInitialized = true
                return
            }
            
            logSuccess("vocal assistant initialized")
            self.isAssistantInitialized = true
            self.conversationManager = vocalAssistant.newConversation(
                withMessage: self.config.startConversationQuestion,
                andDefaultErrorMessage: self.config.errorResponse
            )
            
            self.assistantAnswerText = self.config.startConversationQuestion
        }
    }
}

#Preview {
    PaymentsVocalAssistantView(
        userContacts: [],
        userBankAccounts: []
    )
}
