//
//  TestAppFormView.swift
//  PaymentsVocalAssistant_testApp
//
//  Created by Mario Mastrandrea on 06/02/24.
//

import SwiftUI

struct TestAppFormView: View {
    private let text: String
    private let size: Double
    private let formUrl: String
    private let formLabel: String
    
    init(text: String, size: Double, formUrl: String, formLabel: String) {
        self.text = text
        self.size = size
        self.formUrl = formUrl
        self.formLabel = formLabel
    }
    
    var body: some View {
        VStack {
            Text(self.text)
                .font(.system(size: self.size))
            
            Spacer()
            
            VStack {
                Link(
                    destination: URL(string: self.formUrl)!,
                    label: {
                        Text(self.formLabel)
                            .bold()
                            .font(.system(size: self.size))
                            .foregroundColor(Color.primary)
                            .frame(maxWidth: .infinity)
                    }
                )
                .padding(20)
                .background(Color.orange)
                .cornerRadius(10)
            }
            
            Spacer()
        }
    }
}

#Preview {
    TestAppFormView(
        text: "test TestAppFormView",
        size: 15.5,
        formUrl: "Url",
        formLabel: "Go to form"
    )
}
