//
//  VocalAssistantContact.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 24/01/24.
//

import Foundation

/** Object representing a unique contact in the app for the `PaymentsVocalAssistant`
    
    It is characterized by a `name` property which will be used by the vocal assistant to identify the requested contact in the speeches */
public struct VocalAssistantContact: CustomStringConvertible {
    /** Unique id representing the contact in the app context */
    public let id: String
    
    /** First name of the contact which will be matched by the vocal assistant */
    public let firstName: String
    
    /** Last name of the contact which will be matched by the vocal assistant */
    public let lastName: String
    
    public var description: String {
        return "\(self.firstName) \(self.lastName)".trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public init(id: String, firstName: String, lastName: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
    }
}
