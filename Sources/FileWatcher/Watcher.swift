//
//  Watcher.swift
//  Watcher
//
//  Created by Benjamin Herzog on 18.08.17.
//

import Foundation

public let fileManager = FileManager.default

public enum State {
    case started(UpdateClosure)
    case stopped
}

public typealias UpdateClosure = () -> Void

protocol WatcherProtocol {
    var state: State { get }
    
    init(path: String, queue: DispatchQueue, interval: TimeInterval) throws
    func start(closure: @escaping UpdateClosure) throws
    func stop()
}

extension FileManager {
    func isDirectory(path: String) -> Bool {
        var directory: ObjCBool = false
        let exists = self.fileExists(atPath: path, isDirectory: &directory)
        return exists && directory.boolValue
    }
}

public class Watcher: WatcherProtocol {
    
    public enum Error: Swift.Error {
        case notADirectory(path: String)
        case alreadyStarted(path: String)
    }
    
    public var state = State.stopped
    
    public let path: String
    private let queue: DispatchQueue
    private let interval: Int
    
    private var hash: String?
    
    public required init(path: String = fileManager.currentDirectoryPath, queue: DispatchQueue, interval: TimeInterval = 2) throws {
        guard fileManager.isDirectory(path: path) else {
            throw Error.notADirectory(path: path)
        }
        self.path = path
        self.queue = queue
        self.interval = Int(interval * 1000)
    }
    
    private var timer: DispatchSourceTimer?
    
    public func start(closure: @escaping UpdateClosure) throws {
        guard case .stopped =  self.state else {
            throw Error.alreadyStarted(path: self.path)
        }
        self.state = .started(closure)
        
        self.timer?.cancel()
        let timer = DispatchSource.makeTimerSource(queue: self.queue)
        timer.schedule(deadline: .now(), repeating: .milliseconds(self.interval))
        timer.setEventHandler(handler: self.timerFired)
        timer.resume()
        self.timer = timer
    }
    
    func timerFired() {
        guard case let .started(closure) = self.state else {
            self.timer?.cancel()
            return
        }
        let newHash = self.calculateHash()
        if newHash != self.hash {
            closure()
        }
        self.hash = newHash
    }
    
    public func stop() {
        self.timer?.cancel()
    }
    
    private func calculateHash() -> String {
        return runShell("shasum \(self.path)/**/*.swift | shasum").out ?? ""
    }
    
}

private func runShell(_ script: String) -> (out: String?, err: String?) {
    let out = Pipe()
    let err = Pipe()
    
    let process = Process()
    process.launchPath = "/usr/bin/env"
    process.arguments = ["zsh", "-c", script]
    process.standardOutput = out
    process.standardError = err
    
    process.launch()
    process.waitUntilExit()
    
    let outData = out.fileHandleForReading.readDataToEndOfFile()
    let outString = String(data: outData, encoding: .utf8)
    
    let errData = out.fileHandleForReading.readDataToEndOfFile()
    let errString = String(data: errData, encoding: .utf8)
    return (outString, errString)
}
