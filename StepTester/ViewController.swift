//
//  ViewController.swift
//  StepTester
//
//  Created by Jay Tucker on 2/16/18.
//  Copyright © 2018 Imprivata. All rights reserved.
//

import UIKit
class ViewController: UIViewController {
    
    private let testRunner = TestRunner(speaker: VoiceSpeaker())

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.testRunner.start()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.testRunner.stop()
        }

//        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
//            self.speaker.speak("Walk")
//        }
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 12) {
//            self.speaker.speak("Done")
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

