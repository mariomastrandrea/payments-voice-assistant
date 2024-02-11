//
//  SpeechConfig.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 16/01/24.
//

import Foundation

enum SpeechConfig {
    static let defaultLocaleId = "en_US"
    static let defaultLocaleIdWithDash = "en-US"
    static let defaultStartDelayMs = 100
    static let speechUtteranceRateMultiplier = Float(1.04)
    
    enum CustomLM {
        static let templatesFileName = "payments_templates.csv"
        static let modelFileName = "customLM_PaymentsVocalAssistant.bin"
        static let identifier = "it.payreply.mastrandrea.m.PaymentsVocalAssistant"
    }
}
