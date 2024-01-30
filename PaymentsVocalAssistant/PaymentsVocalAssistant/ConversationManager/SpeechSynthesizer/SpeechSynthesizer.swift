//
//  SpeechSynthesizer.swift
//  PaymentsVocalAssistant
//
//  Created by Mario Mastrandrea on 29/01/24.
//

import Foundation
import AVFoundation

class SpeechSynthesizer {
    private var language: String
    private var speechSynthesizer: AVSpeechSynthesizer
    
    init() {
        self.language = SpeechConfig.defaultLocaleId
        self.speechSynthesizer = AVSpeechSynthesizer()
    }
    
    func speak(text: String) {
        do {
            // setup audio session
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        }
        catch let error {
            logError("An error occurred during audio session setup for SpeechSynthesizer. \(error.localizedDescription)")
            return
        }
        
        // create the utterance of the provided sentence
        let utterance = AVSpeechUtterance(string: text)
        
        // Configure the utterance's properties here if needed
        utterance.voice = AVSpeechSynthesisVoice(language: self.language)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        
        // Start speaking
        self.speechSynthesizer.speak(utterance)
    }
}

