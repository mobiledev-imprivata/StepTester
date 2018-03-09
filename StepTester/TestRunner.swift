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
    
    private(set) var nSteps: Int = 7
    private(set) var nRounds: Int = 3
    private(set) var roundDuration: TimeInterval = 10
    
    private let pauseDuration: TimeInterval = 3
    
    private let pedometerManager = PedometerManager()
    
    private lazy var speaker: Speaker = {
        let s = Speaker()
        s.delegate = self
        return s
    }()
    
    var delegate: TestRunnerDelegate?
    
    private var currentRound = 0
    
    func updateFromUserDefaults() {
        nSteps = UserDefaults.standard.integer(forKey: "number_of_steps")
        nRounds = UserDefaults.standard.integer(forKey: "number_of_rounds")
        roundDuration = UserDefaults.standard.double(forKey: "duration_of_round")
        
        pedometerManager.interval = roundDuration
    }
    
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
        speaker.speak(message)
    }
    
    private func startRound() {
        currentRound += 1
        speaker.speak("Round \(currentRound). When you hear the word Go, take \(nSteps) steps", delay: pauseDuration)
    }
    
    private func endRound() {
        pedometerManager.queryData { dataString in
            DispatchQueue.main.async {
                self.processPedometerData(pedometerData: dataString)
            }
        }
    }
    
    // must be called on main queue because selectedLocationIndex is determined from UIPickerView selection
    private func processPedometerData(pedometerData: String) {
        let dt = DateFormatter()
        dt.dateFormat = "yyyyMMdd'T'HH-mm-ss"
        let dateString = dt.string(from: Date())
        let selectedLocationIndex = delegate?.selectedLocation() ?? 0
        let message = "\(dateString),\(Device.modelName),\(locations[selectedLocationIndex]),\(currentRound),\(nRounds),\(nSteps),\(pedometerData)"
        Logger.sharedInstance.log(message, toFile: true)
        if currentRound < nRounds {
            speaker.speak("stop")
        } else {
            speaker.speak("done with all rounds")
            delegate?.didFinish()
        }
    }
    
}

extension TestRunner: SpeakerDelegate {
    
    func didFinish(text: String) {
        Logger.sharedInstance.log("didFinish saying \(text)")
        if text.contains("phone") || text.starts(with: "stop") {
            startRound()
        } else if text.starts(with: "Round") {
            delegate?.updateRound(currentRound)
            speaker.speak("ready", delay: 0.5)
        } else if text.starts(with: "ready") {
            speaker.speak("set", delay: 0.25)
        } else if text.starts(with: "set") {
            speaker.speak("go", delay: 0.25)
        } else if text.starts(with: "go") {
            DispatchQueue.main.asyncAfter(deadline: .now() + roundDuration) {
                self.endRound()
            }
        }
    }
    
}
