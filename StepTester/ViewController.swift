//
//  ViewController.swift
//  StepTester
//
//  Created by Jay Tucker on 2/16/18.
//  Copyright © 2018 Imprivata. All rights reserved.
//

import UIKit
import UserNotifications

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
        updateAfterNotification(isSuccess: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFromUserDefaults), name: UserDefaults.didChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(displayLoggerInfo(_:)), name: NSNotification.Name(rawValue: loggerInfoNotification), object: nil)

        requestAuthorizationForNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func requestAuthorizationForNotifications() {
        let options: UNAuthorizationOptions = [.alert]
        UNUserNotificationCenter.current().requestAuthorization(options: options) {
            (granted, error) in
            if !granted {
                Logger.sharedInstance.log("authorization for notifications not granted")
            } else {
                UNUserNotificationCenter.current().delegate = self
            }
        }
    }
    
    @objc private func updateFromUserDefaults() {
        testRunner.updateFromUserDefaults()
        stepsLabel.text = "\(testRunner.nSteps)"
        roundsLabel.text = "\(testRunner.nRounds)"
    }
    
    @objc private func displayLoggerInfo(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let title = userInfo["title"] as? String else { return }
        guard let body = userInfo["body"] as? String else { return }
        
        DispatchQueue.main.async {
            self.updateAfterNotification(isSuccess: title == "Success")
        }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(identifier: "mynotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) {
            error in
            if let error = error {
                Logger.sharedInstance.log("error scheduling local notification \(error.localizedDescription)")
            }
        }
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
    
    private func updateAfterNotification(isSuccess: Bool) {
        startButton.isEnabled = isSuccess
        deleteButton.isEnabled = !isSuccess
        sendButton.isEnabled = !isSuccess
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

extension ViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert])
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
        // startButton.isEnabled = true
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

