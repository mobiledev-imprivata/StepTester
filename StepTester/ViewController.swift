//
//  ViewController.swift
//  StepTester
//
//  Created by Jay Tucker on 2/16/18.
//  Copyright © 2018 Imprivata. All rights reserved.
//

import UIKit
class ViewController: UIViewController {
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var roundsLabel: UILabel!
    @IBOutlet weak var currentRoundLabel: UILabel!
    
    private var testRunner = TestRunner()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        pickerView.dataSource = self
        pickerView.delegate = self

        stepsLabel.text = "\(testRunner.nSteps)"
        roundsLabel.text = "\(testRunner.nRounds)"
        currentRoundLabel.text = "0"
        
        testRunner.speaker = Speaker()
        testRunner.delegate = self
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
//            self.testRunner.stop()
//        }
//
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
    
    @IBAction func startTest(_ sender: Any) {
        testRunner.start()
    }
    
    @IBAction func deleteData(_ sender: Any) {
        Logger.sharedInstance.delete()
    }
    
    @IBAction func sendData(_ sender: Any) {
        Logger.sharedInstance.upload()
    }
    
}

extension ViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 5
    }
    
}

extension ViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .spellOut
        return numberFormatter.string(for: row + 1)?.capitalized
    }
    
}

extension ViewController: TestRunnerDelegate {
    func didStart() {
        print("didStart")
        currentRoundLabel.text = "0"
    }
    
    func didEnd() {
        print("didEnd")
        currentRoundLabel.text = "0"
    }
    
    func updateRound(_ round: Int) {
        print("updateRound \(round)")
        currentRoundLabel.text = "\(round)"
    }
    
}

