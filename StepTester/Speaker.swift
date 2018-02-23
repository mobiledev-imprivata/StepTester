//
//  Speaker.swift
//  StepTester
//
//  Created by Jay Tucker on 2/20/18.
//  Copyright © 2018 Imprivata. All rights reserved.
//

import Foundation
import AVFoundation


protocol SpeakerDelegate {
    func didFinish(text: String)
}

final class Speaker: NSObject {
    
    private let synthesizer = AVSpeechSynthesizer()
    
    var delegate: SpeakerDelegate?
    
    override init() {
        super.init()
        synthesizer.pauseSpeaking(at: .word)
        synthesizer.delegate = self
    }

    func speak(_ message: String, delay: TimeInterval = 0.0) {
        Logger.sharedInstance.log(message)
        let utterance = AVSpeechUtterance(string: message)
        utterance.preUtteranceDelay = delay
        let language = UserDefaults.standard.string(forKey: "voice")
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        synthesizer.speak(utterance)
    }

}

extension Speaker: AVSpeechSynthesizerDelegate {
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        delegate?.didFinish(text: utterance.speechString)
    }
    
}
