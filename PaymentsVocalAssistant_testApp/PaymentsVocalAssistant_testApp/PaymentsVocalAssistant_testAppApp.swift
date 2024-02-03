//
//  PaymentsVocalAssistant_testAppApp.swift
//  PaymentsVocalAssistant_testApp
//
//  Created by Mario Mastrandrea on 16/01/24.
//

import SwiftUI
import PaymentsVocalAssistant
import Contacts

@main
struct PaymentsVocalAssistant_testAppApp: App {
    let contactStore: CNContactStore
    
    @State private var userContacts: [VocalAssistantContact] = []
    @State private var userBankAccounts: [VocalAssistantBankAccount] = []
    
    @State private var contactsInitializationCompleted: Bool = false
    @State private var bankAccountsInitializationCompleted: Bool = false
    
    private var initializationCompleted: Bool {
        return self.contactsInitializationCompleted && self.bankAccountsInitializationCompleted
    }
    
    init() {
        self.contactStore = CNContactStore()
    }
    
    var body: some Scene {
        WindowGroup {
            
            if !self.initializationCompleted {
                VocalAssistantActivityIndicator()
                    .onAppear { self.initContactsAndBankAccounts() }
            }
            else {
                PaymentsVocalAssistantView(
                    appContext: AppContext(
                        userContacts: userContacts,
                        userBankAccounts: userBankAccounts
                    ),
                    appDelegate: AppDelegateStub()
                )
            }
        }
    }
    
    private func initContactsAndBankAccounts() {
        Task {
            let contacts = await self.fetchContacts()
            
            if let contacts = contacts {
                Task { @MainActor in
                    self.userContacts = contacts
                    self.contactsInitializationCompleted = true
                }
            }
            
            let bankAccounts = self.simulateBankAccounts()
            
            Task { @MainActor in
                self.userBankAccounts = bankAccounts
                self.bankAccountsInitializationCompleted = true
            }
        }
    }
    
    private func fetchContacts() async -> [VocalAssistantContact]? {
        _ = await self.contactStore.askPermissionToAccessContacts()
        
        if !self.isContactsPermissionGranted() { return nil }

        let keysToFetch = [CNContactPhoneNumbersKey, CNContactGivenNameKey, CNContactFamilyNameKey] as [CNKeyDescriptor]
        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
        var contacts: [VocalAssistantContact] = []
        
        do {
            try self.contactStore.enumerateContacts(with: fetchRequest) { (contact, stop) in
                if !contact.phoneNumbers.isEmpty {
                    let number = contact.phoneNumbers[0].value.stringValue
                    let name = contact.givenName
                    let surname = contact.familyName
                    
                    if !number.isEmpty && !(name+surname).isEmpty {
                        let contact = VocalAssistantContact(id: number, firstName: name, lastName: surname)
                        contacts.append(contact)
                        
                        print("\(number) - \((name + " " + surname).trimmingCharacters(in: .whitespacesAndNewlines))")
                    }
                }
                
            }
        }
        catch let error {
            print("Failed to fetch contacts, error: \(error.localizedDescription)")
            return nil
        }
        
        return contacts
    }
    
    private func simulateBankAccounts() -> [VocalAssistantBankAccount] {
        return [
            AppDelegateStub.futureBankAccount,
            AppDelegateStub.topBankAccount
        ]
    }

    private func isContactsPermissionGranted() -> Bool {
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)

        switch authorizationStatus {
        case .authorized:
            print("Access to contacts has been granted.")
            return true
        case .denied:
            print("Access to contacts has been denied.")
            return false
        case .restricted:
            print("Access to contacts is restricted.")
            return false
        case .notDetermined:
            // Access has not been determined.
            self.contactStore.requestAccess(for: .contacts) { granted, error in
                if granted {
                    print("Access to contacts was just granted.")
                } else {
                    print("Access to contacts was just denied or there was an error: \(String(describing: error))")
                }
            }
            return false
        @unknown default:
            print("Unknown authorization status.")
            return false
        }
    }
}

extension CNContactStore {
    func askPermissionToAccessContacts() async -> Bool {
        await withCheckedContinuation { continuation in
            self.requestAccess(for: .contacts) { granted, error in
                continuation.resume(with: .success(granted))
            }
        }
    }
}
