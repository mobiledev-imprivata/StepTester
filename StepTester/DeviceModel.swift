//
//  DeviceModel.swift
//  StepTester
//
//  Created by Jay Tucker on 3/5/18.
//  Copyright © 2018 Imprivata. All rights reserved.
//

import Foundation

struct Device {
    
    static private let deviceModels = [
        "iPhone4,1": "iPhone 4s",
        "iPhone5,1": "iPhone 5",
        "iPhone5,2": "iPhone 5",
        "iPhone5,3": "iPhone 5c",
        "iPhone5,4": "iPhone 5c",
        "iPhone6,1": "iPhone 5s",
        "iPhone6,2": "iPhone 5s",
        "iPhone7,2": "iPhone 6",
        "iPhone7,1": "iPhone 6 Plus",
        "iPhone8,1": "iPhone 6s",
        "iPhone8,2": "iPhone 6s Plus",
        "iPhone8,4": "iPhone SE",
        "iPhone9,1": "iPhone 7",
        "iPhone9,3": "iPhone 7",
        "iPhone9,2": "iPhone 7 Plus",
        "iPhone9,4": "iPhone 7 Plus",
        "iPhone10,1": "iPhone 8",
        "iPhone10,4": "iPhone 8",
        "iPhone10,2": "iPhone 8 Plus",
        "iPhone10,5": "iPhone 8 Plus",
        "iPhone10,3": "iPhone X",
        "iPhone10,6": "iPhone X",
        "x86_64": "Simulator",
        "i386": "Simulator"
    ]
    
    /// Refer to the next wiki for other models numbers if needed at any time:
    /// ## See
    /// [Apple devices models information](https://www.theiphonewiki.com/wiki/Models)
    ///
    static var modelName: String {
        guard let name = deviceModels[rawModelName] else {
            return "unknown"
        }
        return name
    }
    
    /// NB: The device model names returned here are of the type "iPhone4,1", "iPhone7,1", or "iPad4,4".
    /// See the links above to map these names into more common, human-readable ones
    /// like "iPhone 4S", "iPhone 6 Plus", or "iPad mini 2G (WiFi)", resp.
    /// ## see for more info
    /// [Determine Device](http://stackoverflow.com/questions/448162/determine-device-iphone-ipod-touch-with-iphone-sdk)
    /// ## and
    /// [Using sysctlbyname](http://stackoverflow.com/questions/25467082/using-sysctlbyname-from-swift)
    ///
    private static var rawModelName: String {
        var size: Int = 0 // Swift 1.2: var size: Int = 0 (as Ben Stahl noticed in his answer)
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: Int(size))
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        return String(cString: machine)
    }
    
}
