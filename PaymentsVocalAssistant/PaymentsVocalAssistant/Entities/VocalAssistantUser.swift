//
//  VocalAssistantUser.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 24/01/24.
//

import Foundation

/** Object representing a unique user in the app for the `PaymentsVocalAssistant`
    
    It is characterized by a `name` property which will be used by the vocal assistant to identify the requested user in the speeches */
public struct VocalAssistantUser {
    /** Unique id representing the user in the app context */
    let id: String
    
    /** Full name of the user which will be matched by the vocal assistant */
    let name: String
}
