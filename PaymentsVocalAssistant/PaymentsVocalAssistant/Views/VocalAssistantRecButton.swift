//
//  VocalAssistantRecButton.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 29/01/24.
//

import SwiftUI

struct VocalAssistantRecButton: View {
    private let imageName: String
    private let text: String
    private let textColor: Color
    private let fillColor: Color
    private let disabled: Bool
    private let action: () -> Void
    
    private let hapticFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    init(disabled: Bool, imageName: String, text: String, textColor: Color, fillColor: Color, action: @escaping () -> Void) {
        self.disabled = disabled
        self.imageName = imageName
        self.text = text
        self.textColor = textColor
        self.fillColor = fillColor
        self.action = action
    }
    
    struct VocalAssistantRecButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .opacity(configuration.isPressed ? 0.7 : 1.0) // Custom opacity on tap
        }
    }
    
    var body: some View {
        // button to record user's speech
        Button(action: {
            self.action()
        }) {
            HStack {
                Image(systemName: self.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 24)
                    .foregroundColor(self.textColor)
                Text(self.text)
                    .foregroundColor(self.textColor)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(self.fillColor.opacity(self.disabled ? 0.6 : 1.0))
            .cornerRadius(10)
            .padding()
        }
        .disabled(self.disabled)
        .buttonStyle(VocalAssistantRecButtonStyle())
    }
}

#Preview {
    VocalAssistantRecButton(
        disabled: false,
        imageName: "mic.fill",
        text: "Hold to speak",
        textColor: Color.white,
        fillColor: Color.blue,
        action: {}
    )
}
