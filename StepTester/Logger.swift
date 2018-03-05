//
//  Logger.swift
//  StepTester
//
//  Created by Jay Tucker on 2/20/18.
//  Copyright © 2018 Imprivata. All rights reserved.
//

import Foundation

let loggerInfoNotification = "com.imprivata.loggerInfo"

public final class Logger {
    
    // singleton
    static let sharedInstance = Logger()

    private var messageBuffer = [String]()
    private let messageBufferMaxSize = 10
    
    private var logFilePath: String?
    private var outputStream: OutputStream?
    
    private let loggerQueue = DispatchQueue(label: "com.imprivata.log", attributes: [])
    private let uploadQueue = DispatchQueue(label: "com.imprivata.upload", attributes: [])
    
    private var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "YYYY-MM-dd HH:mm:ss.SSS"
        return df
    }()
    
    private init() {}
    
    deinit {
        closeFile()
        deleteFile()
    }
    
    func log(_ message: String, toFile: Bool = false) {
        loggerQueue.async { [unowned self] in
            let timestamp = self.dateFormatter.string(from: Date())
            let logString = timestamp + " " + (toFile ? "*** " : "") + message
            print(logString)
            
            if !toFile { return }
            
            self.messageBuffer.append(message)
            print("messageBuffer \(self.messageBuffer.count)")
            if self.messageBuffer.count >= self.messageBufferMaxSize {
                self.writeBufferToFile()
            }
        }
    }
    
    func upload() {
        print(#function)
        loggerQueue.async { [unowned self] in
            // flush any remaining messages in the message buffer, then close the file
            self.writeBufferToFile()
            self.closeFile()
            self.uploadFileToServer()
        }
    }
    
    func delete() {
        print(#function)
        loggerQueue.async { [unowned self] in
            self.closeFile()
            self.deleteFile()
            self.messageBuffer.removeAll(keepingCapacity: true)
            self.displayInfoNotification(title: "Success", body:"Data deleted.")
        }
    }
    
    // MARK: OutputStream/file code
    
    private func openFile() {
        print(#function)
        let pathArray = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        if !pathArray.isEmpty {
            let path = pathArray[0]
            logFilePath = "\(path)/logfile"
            print("opening logFilePath \(logFilePath!)")
            outputStream = OutputStream(toFileAtPath: logFilePath!, append: true)
            outputStream?.open()
        }
    }
    
    private func closeFile() {
        print(#function)
        outputStream?.close()
        outputStream = nil
    }
    
    private func deleteFile() {
        guard let logFilePath = logFilePath else { return }
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: logFilePath) {
            do {
                try fileManager.removeItem(atPath: logFilePath)
                print("delete \(logFilePath) ok")
            } catch let error as NSError {
                print("delete \(logFilePath) failed: \(error.localizedDescription)")
            }
        }
        self.logFilePath = nil
        outputStream = nil
    }
    
    private func writeBufferToFile() {
        print(#function)
        if outputStream == nil {
            openFile()
        }
        if let outputStream = outputStream {
            let s = messageBuffer.reduce("") { $0 + $1 + "\\n" }
            let nBytesWritten = outputStream.write(s, maxLength: s.lengthOfBytes(using: .utf8))
            if nBytesWritten != -1 {
                messageBuffer.removeAll(keepingCapacity: true)
            } else {
                print("error writing log file")
            }
        } else {
            print("cannot open log file")
        }
    }
    
    private func uploadFileToServer() {
        print(#function)
        
        guard let logFilePath = logFilePath else { return }
        
        let contentString: String
        do {
            contentString = try String(contentsOfFile: logFilePath, encoding: .utf8)
        } catch  let error as NSError {
            print("Failed reading from \(logFilePath), Error: \(error.localizedDescription)")
            return
        }
        
        guard !contentString.isEmpty else {
            print("File \(logFilePath) is empty")
            return
        }
        
        print("content character count: \(contentString.count)")
        
        let nEntries = contentString.components(separatedBy: "\\n").filter { !$0.isEmpty }.count
        
        let jsonString = "{ \"text\": \"\(contentString)\" }"
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("error converting JSON string to data")
            return
        }
        
        print("JSON data count: \(jsonData.count)")
        
        uploadQueue.async {
            print("uploading...")
            // let urlString = "http://10.18.0.251:5000/upload" // ifconfig | grep inet
            let urlString = "http://10.113.212.22:5000/upload"
            let url = URL(string: urlString)!
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
                guard error == nil else {
                    print("error: \(error!.localizedDescription)")
                    self.displayInfoNotification(title: "Failure", body: error!.localizedDescription)
                    return
                }
                
                guard let response = response as? HTTPURLResponse else {
                    print("got bad response")
                    self.displayInfoNotification(title: "Failure", body:"got bad response")
                    return
                }
                
                print("response status code \(response.statusCode)")
                if response.statusCode == 200 {
                    self.deleteFile()
                    self.messageBuffer.removeAll(keepingCapacity: true)
                    self.displayInfoNotification(title: "Success", body:"Uploaded \(nEntries) results")
                } else {
                    self.displayInfoNotification(title: "Failure", body:"Got response status \(response.statusCode)")
                }
            }
            task.resume()
        }
    }
    
    private func displayInfoNotification(title: String, body: String) {
        let userInfo = ["title": title, "body": body]
        NotificationCenter.default.post(name: Notification.Name(rawValue: loggerInfoNotification), object: self, userInfo: userInfo)
    }

}
