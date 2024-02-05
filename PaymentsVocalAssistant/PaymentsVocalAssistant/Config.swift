//
//  config.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 16/01/24.
//

import Foundation
import SwiftUI

enum GlobalConfig {
    static var enableLogs = true
}

public enum DefaultVocalAssistantConfig {
    // unchangeable
    static let uncertaintyThreshold = Float32(0.8)
    static let similarityThreshold = 0.75
    
    // * UI *
    public static let defaultBackgroundColor = Color.clear
    
    // title
    public static let defaultVocalAssistantTitle = "Payments Vocal Assistant"
    public static let defaultTitleTextColor = Color.primary
    
    // answer box
    public static let defaultAssistantAnswerTextColor = Color.primary
    public static let defaultAssistantAnswerBoxBackground = CustomColor.customGray
    
    // rec button
    public static let defaultRecButtonImageName = "mic.fill"
    public static let defaultRecButtonText = "Hold to speak"
    public static let defaultRecButtonFillColor = Color.blue
    public static let defaultRecButtonForegroundColor = Color.white
    
    // * Vocal Assistant *
    
    // sentences
    public static let defaultStartConversation = "Hi! I can assist you performing some money operations inside the app."
    public static let defaultAssistantInitializationErrorMessage = "Sorry, an error occurred during my initialization, we apologize for the inconvenience. Please exit and try again later.\nIf the error persists, check in your System Preferences that this app has both 'Speech Recognition' and 'Microphone' permissions."
    public static let defaultErrorResponse = "Sorry, an error occurred processing your request. Let's try again."
    
    enum DST {
        public static let intentNotChosenResponse = "I'm sorry, I cannot help you with that. I can assist you sending some money, requesting some money or checking info about your bank accounts."
    }
}

public struct VocalAssistantCustomConfig {
    // * UI *
    let backgroundColor: Color
    
    // title
    let title: String
    let titleTextColor: Color
    
    // answer box
    let assistantAnswerBoxTextColor: Color
    let assistantAnswerBoxBackground: Color
    
    // rec button
    let recButtonImageName: String
    let recButtonText: String
    let recButtonFillColor: Color
    let recButtonForegroundColor: Color
    
    // * Vocal Assistant *
    
    // sentences
    let startConversationQuestion: String
    let assistantInitializationErrorMessage: String
    let errorResponse: String
    
    
    public init(
        backgroundColor: Color = DefaultVocalAssistantConfig.defaultBackgroundColor,
        title: String = DefaultVocalAssistantConfig.defaultVocalAssistantTitle,
        titleTextColor: Color = DefaultVocalAssistantConfig.defaultTitleTextColor,
        assistantAnswerBoxTextColor: Color = DefaultVocalAssistantConfig.defaultAssistantAnswerTextColor,
        assistantAnswerBoxBackground: Color = DefaultVocalAssistantConfig.defaultAssistantAnswerBoxBackground,
        recButtonImageName: String = DefaultVocalAssistantConfig.defaultRecButtonImageName,
        recButtonText: String = DefaultVocalAssistantConfig.defaultRecButtonText,
        recButtonFillColor: Color = DefaultVocalAssistantConfig.defaultRecButtonFillColor,
        recButtonForegroundColor: Color = DefaultVocalAssistantConfig.defaultRecButtonForegroundColor,
        startConversationQuestion: String = DefaultVocalAssistantConfig.defaultStartConversation,
        assistantInitializationErrorMessage: String = DefaultVocalAssistantConfig.defaultAssistantInitializationErrorMessage,
        errorResponse: String = DefaultVocalAssistantConfig.defaultErrorResponse
    ) {
        self.backgroundColor = backgroundColor
        
        self.title = title
        self.titleTextColor = titleTextColor
        
        self.assistantAnswerBoxTextColor = assistantAnswerBoxTextColor
        self.assistantAnswerBoxBackground = assistantAnswerBoxBackground
        
        self.recButtonImageName = recButtonImageName
        self.recButtonText = recButtonText
        self.recButtonFillColor = recButtonFillColor
        self.recButtonForegroundColor = recButtonForegroundColor
        
        self.startConversationQuestion = startConversationQuestion
        self.assistantInitializationErrorMessage = assistantInitializationErrorMessage
        self.errorResponse = errorResponse
    }
}
