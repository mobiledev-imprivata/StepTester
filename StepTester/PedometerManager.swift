//
//  PedometerManager.swift
//  StepTester
//
//  Created by Jay Tucker on 2/23/18.
//  Copyright © 2018 Imprivata. All rights reserved.
//

import Foundation
import CoreMotion

final class PedometerManager {
    
    static let errorValue = "error"
    
    var interval: TimeInterval = 10.0 {
        didSet {
            Logger.sharedInstance.log("setting pedometer interval from \(oldValue) to \(interval)")
        }
    }
    
    private let pedometer = CMPedometer()
    
    init() {
        // this is just for internal debugging
        startPedometerUpdates()
        if #available(iOS 10.0, *) {
            startPedometerEventUpdates()
        }
    }
    
    private func startPedometerUpdates() {
        guard CMPedometer.isDistanceAvailable() else { return }
        
        pedometer.startUpdates(from: Date()) { data, error in
            guard error == nil else {
                Logger.sharedInstance.log("pedom error")
                return
            }
            guard let data = data else {
                Logger.sharedInstance.log("pedom data is nil")
                return
            }
            Logger.sharedInstance.log("pedom \(data.numberOfSteps) \(String(format: "%.3f",data.distance!.doubleValue))")
        }
    }
    
    @available(iOS 10.0, *)
    private func startPedometerEventUpdates() {
        guard CMPedometer.isPedometerEventTrackingAvailable() else { return }
        
        pedometer.startEventUpdates { event, error in
            guard error == nil else {
                Logger.sharedInstance.log("pedom event error")
                return
            }
            guard let event = event else {
                Logger.sharedInstance.log("pedom event is nil")
                return
            }
            let typeString: String
            switch event.type {
            case .pause: typeString = "pause"
            case .resume: typeString = "resume"
            }
            Logger.sharedInstance.log("pedom event \(typeString)")
        }
    }
    
    func queryData(completion: @escaping (String) -> Void) {
        let now = Date()
        pedometer.queryPedometerData(from: now - interval, to: now) { data, error in
            guard error == nil else {
                Logger.sharedInstance.log("queryPedometerData error \(error!.localizedDescription)")
                completion(PedometerManager.errorValue)
                return
            }
            guard let data = data else {
                Logger.sharedInstance.log("queryPedometerData data is nil")
                completion(PedometerManager.errorValue)
                return
            }
            completion("\(data.numberOfSteps)")
        }
    }
    
}
