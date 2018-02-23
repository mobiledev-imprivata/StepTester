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
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
    private let testRunner = TestRunner()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        testRunner.delegate = self
        
        pickerView.dataSource = self
        pickerView.delegate = self

        currentRoundLabel.text = "0"
        
        updateFromUserDefaults()
        NotificationCenter.default.addObserver(self, selector: #selector(updateFromUserDefaults), name: UserDefaults.didChangeNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func updateFromUserDefaults() {
        testRunner.updateFromUserDefaults()
        stepsLabel.text = "\(testRunner.nSteps)"
        roundsLabel.text = "\(testRunner.nRounds)"
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
        return testRunner.locations.count
    }
    
}

extension ViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return testRunner.locations[row].capitalized
    }
    
}

extension ViewController: TestRunnerDelegate {
    
    func didStart() {
        Logger.sharedInstance.log("didStart")
        currentRoundLabel.text = "0"
        startButton.isEnabled = false
        deleteButton.isEnabled = false
        sendButton.isEnabled = false
    }
    
    func didFinish() {
        Logger.sharedInstance.log("didFinish")
        currentRoundLabel.text = "0"
        startButton.isEnabled = true
        deleteButton.isEnabled = true
        sendButton.isEnabled = true
    }
    
    func updateRound(_ round: Int) {
        Logger.sharedInstance.log("updateRound \(round)")
        currentRoundLabel.text = "\(round)"
    }
    
    func selectedLocation() -> Int {
        return pickerView.selectedRow(inComponent: 0)
    }

    
}

