//
//  EnumWrapper.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 31/01/24.
//

import Foundation

class ResponseWrapper: ObservableObject {
    @Published var value: VocalAssistantResponse

    init(value: VocalAssistantResponse) {
        self.value = value
    }

    var textAnswer: String {
        value.textAnswer
    }
}
