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
    
    func stopSpeaking() {
        // first stop any previous speech
        self.speechSynthesizer.stopSpeaking(at: .immediate)
    }
    
    func speak(text: String) {
        // first stop any previous speech
        self.stopSpeaking()
        
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
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * Float(1.05)
        
        logInfo("Utterance  ->  Rate: \(utterance.rate)  -  Voice: \(utterance.voice?.name ?? "default")")
        
        // Start speaking
        self.speechSynthesizer.speak(utterance)
    }
}

