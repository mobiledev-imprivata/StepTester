//
//  TestRunner.swift
//  StepTester
//
//  Created by Jay Tucker on 2/20/18.
//  Copyright © 2018 Imprivata. All rights reserved.
//

import Foundation

struct TestRunner {
    
    var speaker: Speaker?
    
    func start() {
        speaker?.speak("Start")
    }
    
    func stop() {
        speaker?.speak("Stop")
    }
    
}
