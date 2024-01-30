//
//  ContentView.swift
//  PaymentsVocalAssistant_testApp
//
//  Created by Mario Mastrandrea on 16/01/24.
//

import SwiftUI
import PaymentsVocalAssistant

struct ContentView: View {    
    // State to control the button's enabled/disabled state
    @State private var isButtonDisabled = false

    var body: some View {
        VStack {
            Button("Click Me") {
                print("Button was tapped")
            }
            .disabled(isButtonDisabled) // Use the state to enable/disable the button
            .padding()
            .background(isButtonDisabled ? Color.gray : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)

            // Toggle button to enable/disable the "Click Me" button
            Button("Toggle Button State") {
                isButtonDisabled.toggle() // Toggle the state to enable/disable the button
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
    }
}

#Preview {
    ContentView()
}
