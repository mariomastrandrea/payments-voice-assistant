//
//  TestAppAssistantDescriptionView.swift
//  PaymentsVocalAssistant_testApp
//
//  Created by Mario Mastrandrea on 06/02/24.
//

import SwiftUI

struct TestAppAssistantDescriptionView: View {
    private let text: String
    private let size: Double
    
    init(text: String, size: Double) {
        self.text = text
        self.size = size
    }
    
    var body: some View {
        VStack {
            Text(self.text)
                .font(.system(size: self.size))
            
            Spacer()
        }
    }
}

#Preview {
    TestAppAssistantDescriptionView(
        text: "test TestAppAssistantDescriptionView",
        size: 15.5
    )
}
