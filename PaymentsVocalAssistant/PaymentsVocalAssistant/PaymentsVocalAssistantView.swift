//
//  PaymentsVocalAssistantView.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 29/01/24.
//

import SwiftUI

public struct PaymentsVocalAssistantView: View {
    // View state
    @State private var conversationManager: ConversationManager!
    @State private var assistantAnswerText: String = ""
    
    @State private var isAssistantInitialized: Bool = false
    @State private var isRecordingInProgress: Bool = false
    @State private var initErrorOccurred: Bool = false
    @State private var assistantInitErrorMessage: String = ""
    
    @State private var chooseAmongBankAccountsFlag: Bool = false
    @State private var bankAccountsList: [VocalAssistantBankAccount] = []
    @State private var chooseAmongContactsFlag: Bool = false
    @State private var contactsList: [VocalAssistantContact] = []
    
    @State private var appErrorFlag: Bool = false
    @State private var appError: String = ""
    
    // app state
    private let appContext: AppContext?
    private let appDelegate: PaymentsVocalAssistantDelegate?
    private let initErrorMessage: String
    private let config: VocalAssistantCustomConfig

    
    public init(
        appContext: AppContext?,
        appDelegate: PaymentsVocalAssistantDelegate?,
        initErrorMessage: String?,
        config: VocalAssistantCustomConfig = VocalAssistantCustomConfig()
    ) {
        self.appContext = appContext
        self.appDelegate = appDelegate
        self.initErrorMessage = initErrorMessage ?? "An unexpected error occurred"
        self.config = config
    
        self.assistantAnswerText = ""
        self.isAssistantInitialized = false
        self.isRecordingInProgress = false
        self.initErrorOccurred = false
        self.assistantInitErrorMessage = ""
        self.chooseAmongBankAccountsFlag = false
        self.bankAccountsList = []
        self.chooseAmongContactsFlag = false
        self.contactsList = []
        self.appErrorFlag = false
        self.appError = ""
    }
    
    public var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                VocalAssistantTitle(
                    self.config.title,
                    color: self.config.titleTextColor
                ).onAppear {
                    Task {
                        await self.initializeVocalAssistant()
                    }
                }
                
                if self.isAssistantInitialized {
                    answerBoxAndSelectionLists
                }
                else if self.initErrorOccurred {
                    VocalAssistantAnswerBox(
                        assistantAnswer: self.assistantInitErrorMessage,
                        textColor: self.config.assistantAnswerBoxTextColor,
                        boxBackground: self.config.assistantAnswerBoxBackground
                    )
                }
                else {
                    VocalAssistantActivityIndicator()
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
                        
                        Task { @MainActor in
                            self.isRecordingInProgress = true
                        }
                    },
                    longPressEndAction: {
                        Task {
                            let assistantResponse = await self.conversationManager.processAndPlayResponse()
                            
                            self.launchTaskToReactTo(assistantResponse: assistantResponse)
                        }
                    }
                )
            }
            .padding(.bottom, 20)
            .padding(.horizontal, 20)
            .background(self.config.backgroundColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // microphone icon in overlay
            if self.isRecordingInProgress {
                OverlayMicrophone(
                    imageName: self.config.recButtonImageName,
                    backgroundColor: CustomColor.customGrayMic
                )
            }
        }
        .animation(.easeInOut, value: self.isRecordingInProgress) // Animate the appearance/disappearance of the microphone overlay
    }
    
    @ViewBuilder
    private var answerBoxAndSelectionLists: some View {
            VocalAssistantAnswerBox(
                assistantAnswer: self.assistantAnswerText,
                textColor: self.config.assistantAnswerBoxTextColor,
                boxBackground: self.config.assistantAnswerBoxBackground
            )
            
            if self.chooseAmongContactsFlag && self.contactsList.isNotEmpty {
                VocalAssistantSelectionList(
                    elements: self.contactsList,
                    color: self.config.assistantAnswerBoxBackground,
                    onTap: { contact in
                        Task {
                            let assistantResponse = await self.conversationManager.userSelects(contact: contact)
                            
                            self.launchTaskToReactTo(assistantResponse: assistantResponse)
                        }
                    }
                )
                .padding(.vertical, 20)
            }
            
            if self.chooseAmongBankAccountsFlag && self.bankAccountsList.isNotEmpty {
                VocalAssistantSelectionList(
                    elements: self.bankAccountsList,
                    color: self.config.assistantAnswerBoxBackground,
                    onTap: { bankAccount in
                        Task {
                            let assistantResponse = await self.conversationManager.userSelects(bankAccount: bankAccount)
                            
                            self.launchTaskToReactTo(assistantResponse: assistantResponse)
                        }
                    }
                )
                .padding(.vertical, 20)
            }
            
            if self.appErrorFlag && self.appError.isNotEmpty {
                VStack {
                    Text(self.appError)
                }
                .foregroundColor(self.config.assistantAnswerBoxTextColor)
                .padding(.all, 18)
                .frame(maxWidth: .infinity, minHeight: 55, alignment: .leading)
                .background(Color.red.opacity(0.7))
                .cornerRadius(10)
            }
        
    }
    
    private func initializeVocalAssistant() async {
        // check that all the Assistant dependencies are correctly injected
        guard let appContext = self.appContext, let appDelegate = self.appDelegate else {
            self.assistantInitErrorMessage = self.initErrorMessage
            self.initErrorOccurred = true
            return
        }
        
        // instantiate the PaymentsVocalAssistant
        guard let vocalAssistant = await PaymentsVocalAssistant.instance(appContext: appContext) else {
            // initialization error occurred
            self.assistantInitErrorMessage = self.config.assistantInitializationErrorMessage
            
            logError("PaymentsVocalAssistant is nil after getting singleton instance")
            self.initErrorOccurred = true
            return
        }
        
        // create a new conversation with the specified opening message and error message
        self.conversationManager = vocalAssistant.newConversation(
            withMessage: self.config.startConversationQuestion,
            andDefaultErrorMessage: self.config.errorResponse,
            appDelegate: appDelegate
        )
        
        self.assistantAnswerText = self.conversationManager.startConversation()
        self.isAssistantInitialized = true
        logSuccess("vocal assistant initialized")
    }
    
    private func launchTaskToReactTo(assistantResponse: VocalAssistantResponse) {
        Task { @MainActor in
            self.isRecordingInProgress = false
            self.assistantAnswerText = assistantResponse.completeAnswer
            
            // reset state
            self.appError = ""
            self.appErrorFlag = false
            self.contactsList = []
            self.chooseAmongContactsFlag = false
            self.bankAccountsList = []
            self.chooseAmongBankAccountsFlag = false
            
            // show/hide list or error
            switch assistantResponse {
            case .appError(let errorMessage, _, _):
                self.appError = errorMessage
                self.appErrorFlag = true
            case .justAnswer(_, _):
                break
            case .askToChooseContact(let contacts, _, _):
                self.contactsList = contacts
                self.chooseAmongContactsFlag = true
            case .askToChooseBankAccount(let bankAccounts, _, _):
                self.bankAccountsList = bankAccounts
                self.chooseAmongBankAccountsFlag = true
            case .performInAppOperation(_, _, _, _, _):
                break
            }
        }
    }
}

#Preview {
    PaymentsVocalAssistantView(
        appContext: AppContext.default,
        appDelegate: AppDelegateStub(),
        initErrorMessage: nil
    )
}
