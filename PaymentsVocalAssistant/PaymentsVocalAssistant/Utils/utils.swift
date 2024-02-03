//
//  Utils.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 16/01/24.
//

import Foundation
import Contacts

internal func fetchContacts(contactStore: CNContactStore) async -> [VocalAssistantContact]? {
    _ = await contactStore.askPermissionToAccessContacts()
    
    if !isContactsPermissionGranted() { return nil }

    let keysToFetch = [CNContactPhoneNumbersKey, CNContactGivenNameKey, CNContactFamilyNameKey] as [CNKeyDescriptor]
    let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
    var contacts: [VocalAssistantContact] = []
    
    do {
        try contactStore.enumerateContacts(with: fetchRequest) { (contact, stop) in
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
        print("Access to contacts is not determined.")
        return false
    @unknown default:
        print("Unknown authorization status.")
        return false
    }
}

internal extension CNContactStore {
    func askPermissionToAccessContacts() async -> Bool {
        await withCheckedContinuation { continuation in
            self.requestAccess(for: .contacts) { granted, error in
                continuation.resume(with: .success(granted))
            }
        }
    }
}


// MARK: utility functions

func delay(ms: Int) async {
    let seconds = Double(ms) / 1000.0
    await withCheckedContinuation { continuation in
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            continuation.resume()
        }
    }
}

// MARK: utility entities

struct File {
    let name: String
    let _extension: String
    let description: String

    init(name: String, extension _extension: String) {
        self.name = name
        self._extension = _extension
        self.description = "\(name).\(_extension)"
    }
}


