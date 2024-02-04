//
//  VocalAssistantContact.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 24/01/24.
//

import Foundation

/** Object representing a unique contact in the app for the `PaymentsVocalAssistant`
    
    It is characterized by a `name` property which will be used by the vocal assistant to identify the requested contact in the speeches */
public struct VocalAssistantContact: CustomStringConvertible, Hashable {
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
    
    public func match(with literal: String) -> Double? {
        let threshold = DefaultVocalAssistantConfig.similarityThreshold
        
        let similarityWithFullName = self.description.lowercased().similarity(with: literal.lowercased())
        if similarityWithFullName >= threshold {
            return similarityWithFullName
        }
        
        let similarityWithFirstName = self.firstName.lowercased().similarity(with: literal.lowercased())
        let similarityWithLastName = self.lastName.lowercased().similarity(with: literal.lowercased())
        
        if similarityWithFirstName >= threshold {
            return similarityWithFirstName / 2.0
        }
        
        if similarityWithLastName >= threshold {
            return similarityWithLastName / 2.0
        }
        
        // no much similarity
        return nil
    }
    
    public static func == (lhs: VocalAssistantContact, rhs: VocalAssistantContact) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    internal func toEntity() -> PaymentsEntity {
        return PaymentsEntity(
            type: .user,
            reconstructedEntity: self.description,
            entityProbability: Float32(1.0),
            reconstructedTokens: self.description.splitByWhitespace(),
            rawTokens: [],
            tokensLabels: [],
            tokensLabelsProbabilities: []
        )
    }
}

internal extension Array where Element == VocalAssistantContact {
    func keepAndOrderJustTheOnesSimilar(to literal: String) -> Self {
        return self
            .compactMap { // keep just the contacts with high similarity
                (contact: VocalAssistantContact) -> (VocalAssistantContact, Double)? in
                    guard let similarity = contact.match(with: literal)
                        else { return nil }
                    return (contact, similarity)
            }.sorted(by: { // sort them in descending order of similarity
                pair1, pair2 in
                    let (_, similarityContact1) = pair1
                    let (_, similarityContact2) = pair2
                    return similarityContact1 >= similarityContact2
            }).map { $0.0 } // discard the similarity values
    }
}
