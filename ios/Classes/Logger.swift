//
//  File.swift
//  Squares
//
//  Created by Matthias Hochgatterer on 03/12/14.
//  Copyright (c) 2014 Matthias Hochgatterer. All rights reserved.
//
import Foundation
import Dispatch
import Swift

public protocol Output {
    func process(_ string: String)
}

public struct ConsoleOutput: Output {
    private var queue: DispatchQueue
    
    public init() {
        self.queue = DispatchQueue(label: "Console output")
    }
    
    public func process(_ string: String) {
        queue.sync {
            Swift.print(string)
        }
    }
}

public class FileOutput: Output {
    var filePath: String
    var deviceInfo: DeviceInfo?
    private var fileHandle: FileHandle?
    private var queue: DispatchQueue
    
    public init(filePath: String, deviceInfo: DeviceInfo?) {
        self.filePath = filePath
        self.deviceInfo = deviceInfo
        self.queue = DispatchQueue(label: "File output")
        //print(filePath)
    }
    
    deinit {
        fileHandle?.closeFile()
    }
    
    public func process(_ string: String) {
        queue.sync(execute: {
            [weak self] in
            if let file = self?.getFileHandle() {
                let printed = string + "\n"
                if let data = printed.data(using: String.Encoding.utf8) {
                    file.seekToEndOfFile()
                    file.write(data)
                }
            }
        })
    }
    
    
    private func getFileHandle() -> FileHandle? {
        var isFileCreated = false
        if !FileManager.default.fileExists(atPath: filePath) {
            FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
            isFileCreated = true
        }
        let fileHandle = FileHandle(forWritingAtPath: filePath)
        //If file is created then write some common logs in header of file.
        if isFileCreated && deviceInfo != nil {
            let printed = "**************\n \(deviceInfo?.description ?? "") \n ************** \n"
            if let data = printed.data(using: String.Encoding.utf8) {
                fileHandle?.seekToEndOfFile()
                fileHandle?.write(data)
            }
        }
        return fileHandle
    }
}

public class URLOutput: Output {
    var url: URL
    private var fileHandle: FileHandle?
    private var queue: DispatchQueue
    
    public init(url: URL) {
        self.url = url
        self.queue = DispatchQueue(label: "URL output")
    }
    
    deinit {
        fileHandle?.closeFile()
    }
    
    public func process(_ string: String) {
        queue.sync(execute: {
            [weak self] in
            if let file = self?.getFileHandle() {
                let printed = string + "\n"
                if let data = printed.data(using: String.Encoding.utf8) {
                    file.seekToEndOfFile()
                    file.write(data)
                }
            }
        })
    }
    
    
    private func getFileHandle() -> FileHandle? {
        if !FileManager.default.fileExists(atPath: url.absoluteString) {
            FileManager.default.createFile(atPath: url.absoluteString, contents: nil, attributes: nil)
        }
        let fileHandle = FileHandle(forWritingAtPath: url.absoluteString)
        return fileHandle
    }
}

private let _sharedInstance = Logger()
public class Logger {
    public class var sharedInstance: Logger {
        return _sharedInstance
    }
    private var outputs: [Output]
    
    public init() {
        outputs = [Output]()
        outputs.append(ConsoleOutput())
    }
    
    public func addOutput(_ output: Output) {
        if (!outputs.contains(where: {isOutputEqual($0, comparedTo: output)})) {
            outputs.append(output)
        }
    }
    
    public func log(_ string: String) {
        for out in outputs {
            out.process(string)
        }
    }
    
    public func logToFileAndConsoleOnly(_ filePath: String, _ log: String) {
        for out in outputs {
            if(out is ConsoleOutput) {
                out.process(log)
            }
            else if(out is FileOutput) {
                let fileOutput = out as! FileOutput
                let isTargettedFile = fileOutput.filePath == filePath
                if(isTargettedFile) {
                    out.process(log)
                }
            }
        }
    }

    func isOutputEqual(_ existingOutput: Output, comparedTo newOutput: Output) -> Bool {
        //If types are different then no need to check for equality
        guard type(of: existingOutput) == type(of: newOutput) else { return false }

        //FileOutput are compared by filePath
        if let fileOutput = newOutput as? FileOutput, let paramFileOutput = existingOutput as? FileOutput {
            return fileOutput.filePath == paramFileOutput.filePath
        }

        return true
    }

    
}
