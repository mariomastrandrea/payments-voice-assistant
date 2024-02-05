//
//  TestAppMainView.swift
//  PaymentsVocalAssistant_testApp
//
//  Created by Mario Mastrandrea on 05/02/24.
//

import SwiftUI
import PaymentsVocalAssistant
import Contacts

struct TestAppMainView: View {
    private static let title = "Hi there! 🚀"
    private static let buttonLabel = "Start"
    private static let description = """
    My name is Mario Mastrandrea and this is the test application for my Master's Thesis 🎓 in:
       "Developing an AI-Powered Voice Assistant for an iOS Mobile Payment App\"
    
    Thank you for joining this test! 🙏🏻
    
    ✅  The app is intended to test the performance of my Voice Assistant 🤖, which will then be integrated into an  application involving P2P payments 📲
    
    ✅  You will take the part of a registered user who has some bank accounts 🏦 and can send to or request money from other users, as well as checking your last transactions 🧾
    
    ✅  My Voice Assistant ⚙️ can help the user perform only the following tasks:
        💸  send some money to another user
        💰  request some money from another user
        📈  checking the balance of a bank account
        💳  checking the last transactions (eventually involving a specific user or bank account)
    
    ✅  Once you are done with your tests, please 🙏🏻 fill out the following form ✏️ to leave your feedbacks (they will be a fundamental part of my Thesis work 📊):
    """
        
    private static let formUrl = "https://forms.gle/EVn8UkvKaEVwHADo6"
    
    let contactStore: CNContactStore
    
    @State private var appDelegateStub: PaymentsVocalAssistantDelegate? = nil
    @State private var appContext: AppContext? = nil
    @State private var initErrorMessage: String? = nil
    @State private var appInitializationCompleted: Bool = false
    @State private var appIsInitializing: Bool = false
    
    init() {
        self.contactStore = CNContactStore()
        
        self.appDelegateStub = nil
        self.appContext = nil
        self.initErrorMessage = nil
        self.appInitializationCompleted = false
        self.appIsInitializing = false
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .center, spacing: 5) {
                    Text(TestAppMainView.title)
                        .bold()
                        .font(.largeTitle)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 15)
                    
                    VStack {
                        Text(TestAppMainView.description)
                            .font(.system(size: 15.5))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack {
                        Link(
                            destination: URL(string: TestAppMainView.formUrl)!,
                            label: {
                                Text(TestAppMainView.formUrl)
                            }
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 5)

                    // button to start the Voice Assistant
                    Button(
                        action: {
                            self.appIsInitializing = true
                            
                            self.initContactsAndBankAccounts()
                        },
                        label: {
                            if self.appIsInitializing {
                                VocalAssistantActivityIndicator()
                            }
                            else {
                                Text(TestAppMainView.buttonLabel)
                                    .bold()
                            }
                        }
                    )
                    .frame(width: 70, height: 70)
                    .padding(20)
                    .background(Color.blue)
                    .cornerRadius(2000)
                    .padding(.vertical, 10)
                    .foregroundColor(Color.white)
                    
                    NavigationLink(
                        destination: PaymentsVocalAssistantView(
                            appContext: self.appContext,
                            appDelegate: self.appDelegateStub,
                            initErrorMessage: self.initErrorMessage
                        ),
                        isActive: self.$appInitializationCompleted
                    ) {
                        EmptyView()
                    }
                    .hidden()
                }
                .padding(.horizontal, 26)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationTitle("Menu")
                .navigationBarTitleDisplayMode(.inline)
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
                    
                    self.appIsInitializing = false
                    
                    // Trigger the navigation
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
                
                self.appIsInitializing = false
                
                // Trigger the navigation
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

#Preview {
    TestAppMainView()
}

