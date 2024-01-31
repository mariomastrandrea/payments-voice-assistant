//
//  TypewriterText.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 29/01/24.
//

import SwiftUI
import Combine

class TextWrapper: ObservableObject {
    @Published var text: String = ""
}

struct TypewriterText: View {
    static let defaultSpeed: TimeInterval = 0.02
    var speed: TimeInterval  // Speed of the typewriter effect

    @ObservedObject private var textWrapper = TextWrapper()
    @State private var displayedText: String = ""
    @State private var charIndex: Int = 0
    
    @State private var timerSubscription: AnyCancellable?
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    
    init(_ text: String, speed: TimeInterval = defaultSpeed) {
        self.speed = speed
        self.textWrapper.text = text
    }
        
    var body: some View {
        Text(self.displayedText)
            .onReceive(self.textWrapper.$text) { newText in
                self.displayedText = ""
                self.charIndex = 0
                
                self.feedbackGenerator.prepare()
                let timer = Timer.publish(every: self.speed, on: .main, in: .common).autoconnect()
                
                self.timerSubscription = timer.sink { _ in
                    if self.charIndex < newText.count {
                        let index = newText.index(newText.startIndex, offsetBy: self.charIndex)
                        let newChar = newText[index]
                        self.displayedText += String(newChar)
                        self.charIndex += 1
                    
                        if newChar.isWhitespace {
                            // for each new word
                            self.feedbackGenerator.impactOccurred()
                        }
                    }
                    else {
                        self.feedbackGenerator.impactOccurred()
                        // unsubscribe
                        self.timerSubscription?.cancel()
                    }
                }
            }
            .onDisappear {
                self.timerSubscription?.cancel()
            }
    }
}

#Preview {
    TypewriterText("This is an example of text inside the Vocal assistant answer box")
}
