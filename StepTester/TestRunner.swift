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
    func didEnd()
    func updateRound(_ round: Int)
}

struct TestRunner {
    
    let nSteps = 7
    let nRounds = 12
    let testDuration = 10
    let pauseDuration = 3

    var speaker: Speaker?

    var delegate: TestRunnerDelegate?

    func start() {
        // speaker?.speak("Start")
        
        delegate?.didStart()
        
        for i in 1...nRounds {
            delegate?.updateRound(i)
            Logger.sharedInstance.log("\(i)")
        }
        
        delegate?.didEnd()
    }
    
}
