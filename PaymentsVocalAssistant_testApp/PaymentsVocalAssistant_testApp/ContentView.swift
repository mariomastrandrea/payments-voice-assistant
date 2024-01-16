//
//  ContentView.swift
//  PaymentsVocalAssistant_testApp
//
//  Created by Mario Mastrandrea on 16/01/24.
//

import SwiftUI
import PaymentsVocalAssistant

struct ContentView: View {
    let a = BertTextClassifier(a: "", b: "")
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.blue)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
