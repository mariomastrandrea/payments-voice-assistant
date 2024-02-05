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
struct TestAppMainView: App {
    let contactStore: CNContactStore
    
    @State private var appDelegateStub: PaymentsVocalAssistantDelegate? = nil
    @State private var appContext: AppContext? = nil
    @State private var initErrorMessage: String? = nil
    @State private var appInitializationCompleted: Bool = false
    
    init() {
        self.contactStore = CNContactStore()
        
        self.appDelegateStub = nil
        self.appContext = nil
        self.initErrorMessage = nil
        self.appInitializationCompleted = false
    }
    
    var body: some Scene {
        WindowGroup {
            if self.appInitializationCompleted {
                PaymentsVocalAssistantView(
                    appContext: self.appContext,
                    appDelegate: self.appDelegateStub,
                    initErrorMessage: self.initErrorMessage
                )
            }
            else {
                VocalAssistantActivityIndicator()
                    .onAppear { self.initContactsAndBankAccounts() }
            }
        }
    }
    
    private func initContactsAndBankAccounts() {
        Task {
            // fetch contacts
            let contacts = await self.fetchContacts()
            
            guard let contacts = contacts else {
                Task { @MainActor in
                    // an error occurred retrieving contacts
                    self.initErrorMessage = "Sorry, an error occurred in accessing your contacts, we apologize for the inconvenience. Please exit and try again later.\nIf the error persists, check in your System Preferences that this app has the 'Contacts' permission."
                    self.appInitializationCompleted = true
                }
                return
            }
            
            Task { @MainActor in
                let appDelegate = AppDelegateStub(
                    contacts: contacts,
                    transactions: []
                )
                self.appDelegateStub = appDelegate
                self.appContext = AppContext(
                    userContacts: contacts,
                    userBankAccounts: Array(appDelegate.bankAccounts.keys)
                )
                self.appInitializationCompleted = true
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
