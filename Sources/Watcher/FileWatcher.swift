//
//  FileWatcher.swift
//  Watcher
//
//  Created by Benjamin Herzog on 18.08.17.
//

import Foundation

enum State {
    case started(UpdateClosure)
    case stopped
}

typealias UpdateClosure = () -> Void

extension FileManager {
    func isDirectory(path: String) -> Bool {
        var directory: ObjCBool = false
        let exists = self.fileExists(atPath: path, isDirectory: &directory)
        return exists && directory.boolValue
    }
}

class FileWatcher {
    
    enum Error: Swift.Error, CustomStringConvertible {
        case notADirectory(path: String)
        case alreadyStarted(path: String)
        
        var description: String {
            switch self {
            case let .notADirectory(path):
                return "The given path is not a directory. (\(path))"
            case let .alreadyStarted(path):
                return "The FileWatcher instance is already running \(path). This is an internal error, please submit a bug report at https://github.com/BenchR267/Watcher. Thanks!"
            }
        }
    }
    
    var state = State.stopped
    
    let path: String
    private let queue: DispatchQueue
    private let interval: Int
    
    private var hash: String?
    private var timer: DispatchSourceTimer?
    
    // MARK: - API
    
    required init(path: String = fileManager.currentDirectoryPath, queue: DispatchQueue, interval: TimeInterval = 2) throws {
        guard fileManager.isDirectory(path: path) else {
            throw Error.notADirectory(path: path)
        }
        self.path = path
        self.queue = queue
        self.interval = Int(interval * 1000)
    }
    
    deinit {
        self.stop()
    }
    
    func start(closure: @escaping UpdateClosure) throws {
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

    public func stop() {
        self.timer?.cancel()
    }

    // MARK: - Helpers
    
    private func timerFired() {
        guard case let .started(closure) = self.state else {
            self.timer?.cancel()
            return
        }
        let newHash = self.calculateHash()
        if let savedHash = self.hash, savedHash != newHash {
            self.queue.sync(execute: closure)
        }
        self.hash = newHash
    }
    
    private func calculateHash() -> String {
        return runShell("shasum \(self.path)/**/*.swift | shasum").out ?? ""
    }
    
}
