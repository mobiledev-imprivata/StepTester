//
//  Speaker.swift
//  StepTester
//
//  Created by Jay Tucker on 2/20/18.
//  Copyright © 2018 Imprivata. All rights reserved.
//

import Foundation
import AVFoundation

struct Speaker {
    
    private let synthesizer = AVSpeechSynthesizer()

     func speak(_ message: String) {
        Logger.sharedInstance.log(message)
        let utterance = AVSpeechUtterance(string: message)
        // utterance.voice = AVSpeechSynthesisVoice(language: "en-AU")
        synthesizer.pauseSpeaking(at: .word)
        synthesizer.speak(utterance)
    }

}
