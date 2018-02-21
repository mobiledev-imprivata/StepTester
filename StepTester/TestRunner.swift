//
//  TestRunner.swift
//  StepTester
//
//  Created by Jay Tucker on 2/20/18.
//  Copyright © 2018 Imprivata. All rights reserved.
//

import Foundation

protocol TestRunnerDelegate {
    func didStart()
    func didFinish()
    func updateRound(_ round: Int)
    func selectedLocation() -> Int
}

final class TestRunner {
    
    let locations = [
        "back pants pocket",
        "front pants pocket",
        "front shirt pocket",
        "looking at phone"
    ]
    
    let nSteps = 7
    let nRounds = 2
    let testDuration = 3
    let pauseDuration = 2

    var speaker: Speaker? {
        didSet {
            speaker?.delegate = self
        }
    }
    var delegate: TestRunnerDelegate?
    
    private var currentRound = 0

    func start() {
        delegate?.didStart()
        currentRound = 0
        
        let selectedLocation = delegate?.selectedLocation() ?? 0
        let message: String
        if locations[selectedLocation].contains("looking") {
            message = "walk while looking at your phone"
        } else {
            message = "put your phone in your \(locations[selectedLocation])"
        }
        speaker?.speak(message)
    }
    
    private func doRoundPreamble() {
        currentRound += 1
        delegate?.updateRound(currentRound)
        speaker?.speak("round \(currentRound) take \(nSteps) steps")
    }
    
    private func startRound() {
        speaker?.speak("go")
        DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(testDuration)) {
            self.endRound()
        }
    }
    
    private func endRound() {
        let dt = DateFormatter()
        dt.dateFormat = "yyyyMMdd'T'HH-mm-ss"
        let dateString = dt.string(from: Date())
        let selectedLocationIndex = delegate?.selectedLocation() ?? 0
        let message = "\(dateString),\(locations[selectedLocationIndex]),\(currentRound),\(nRounds),\(nSteps),n"
        Logger.sharedInstance.log(message, toFile: true)
        if currentRound < nRounds {
            speaker?.speak("stop")
            DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(pauseDuration)) {
                self.doRoundPreamble()
            }
        } else {
            speaker?.speak("done with all rounds")
            delegate?.didFinish()
        }
    }
    
    
}

extension TestRunner: SpeakerDelegate {
    
    func didFinish(text: String) {
        Logger.sharedInstance.log("didFinish saying \(text)")
        if text.contains("phone") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.doRoundPreamble()
            }
        } else if text.starts(with: "round") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.speaker?.speak("ready")
            }
        } else if text.starts(with: "ready") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.speaker?.speak("set")
            }
        } else if text.starts(with: "set") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.startRound()
            }
        }
    }
    
}
