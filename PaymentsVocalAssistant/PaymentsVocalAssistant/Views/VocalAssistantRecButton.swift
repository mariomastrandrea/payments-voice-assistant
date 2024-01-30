//
//  VocalAssistantRecButton.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 29/01/24.
//

import SwiftUI

struct VocalAssistantRecButton: View {
    @GestureState private var isLongPressed = false

    private let disabled: Bool
    private let imageName: String
    private let text: String
    private let textColor: Color
    private let fillColor: Color
    private let longPressStartAction: () -> Void
    private let longPressEndAction: () -> Void
    
    private let hapticFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    private var longPressMinimumDurationInSec: Double {
        return Double(SpeechConfig.defaultStartDelayMs) / 1000.0
    }
    
    init(disabled: Bool, imageName: String, text: String, textColor: Color, fillColor: Color, longPressStartAction: @escaping () -> Void, longPressEndAction: @escaping () -> Void) {
        self.disabled = disabled
        self.imageName = imageName
        self.text = text
        self.textColor = textColor
        self.fillColor = fillColor
        self.longPressStartAction = longPressStartAction
        self.longPressEndAction = longPressEndAction
    }
    
    struct VocalAssistantRecButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .opacity(configuration.isPressed ? 0.7 : 1.0) // Custom opacity on tap
        }
    }
    
    var body: some View {
        // button to record user's speech
        Button(action: {}) {
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
            .background(self.fillColor.opacity(self.disabled ? 0.6 : self.isLongPressed ? 0.7 : 1.0))
            .cornerRadius(10)
            .padding()
        }
        .highPriorityGesture(
            LongPressGesture(minimumDuration: 0.5)
                .updating($isLongPressed) { currentState, gestureState, transaction in
                    gestureState = currentState
                }
                .onChanged { _ in
                    // This will trigger as soon as the long press gesture starts
                    print("Long press changed")
                }
                .onEnded { _ in
                    // This will trigger when the long press ends
                    
                    // Action to perform when the button is released
                    print("Long Press Ended")
                }
        )
        
    }
}

#Preview {
    VocalAssistantRecButton(
        disabled: false,
        imageName: "mic.fill",
        text: "Hold to speak",
        textColor: Color.white,
        fillColor: Color.blue,
        longPressStartAction: {},
        longPressEndAction: {}
    )
}
