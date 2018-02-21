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
        synthesizer.delegate = self
    }

     func speak(_ message: String) {
        Logger.sharedInstance.log(message)
        let utterance = AVSpeechUtterance(string: message)
        // utterance.voice = AVSpeechSynthesisVoice(language: "en-AU")
        synthesizer.pauseSpeaking(at: .word)
        synthesizer.speak(utterance)
    }

}

extension Speaker: AVSpeechSynthesizerDelegate {
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        delegate?.didFinish(text: utterance.speechString)
    }
    
}
