//
//  TypewriterText.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 29/01/24.
//

import SwiftUI
import Combine

struct TypewriterText: View {
    static let defaultSpeed: TimeInterval = 0.02
    
    let text: String
    var speed: TimeInterval  // Speed of the typewriter effect
    @State private var displayedText: String = ""
    @State private var charIndex: Int = 0
    
    @State private var timerSubscription: AnyCancellable?
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    
    init(_ text: String, speed: TimeInterval = defaultSpeed) {
        self.text = text
        self.speed = speed
    }
        
    var body: some View {
        Text(self.displayedText)
            .onAppear {
                self.feedbackGenerator.prepare()
                let timer = Timer.publish(every: self.speed, on: .main, in: .common).autoconnect()
                
                self.timerSubscription = timer.sink { _ in
                    if self.charIndex < self.text.count {
                        let index = self.text.index(self.text.startIndex, offsetBy: self.charIndex)
                        let newChar = self.text[index]
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
