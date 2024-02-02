//
//  AppContext.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 01/02/24.
//

import Foundation

public struct AppContext {
    public let userContacts: [VocalAssistantContact]
    public let userBankAccounts: [VocalAssistantBankAccount]
    
    public static let `default`: AppContext = AppContext(userContacts: [], userBankAccounts: [])
    
    public init(userContacts: [VocalAssistantContact], userBankAccounts: [VocalAssistantBankAccount]) {
        self.userContacts = userContacts
        self.userBankAccounts = userBankAccounts
    }
}
