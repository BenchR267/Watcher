//
//  MainLoop.swift
//  WatcherPackageDescription
//
//  Created by Benjamin Herzog on 18.08.17.
//

import Foundation
import CLISpinner

class MainLoop {
    
    let path: String
    init(path: String) {
        self.path = path
    }
    
    private var currentSpinner: Spinner?
    
    func start() throws {
        
        let runner = TestRunner(delegate: self, path: path)
        
        while true {
            let semaphore = DispatchSemaphore(value: 0)
            let queue = DispatchQueue(label: "yeah", qos: DispatchQoS.background, attributes: [.concurrent])
            
            let watcher = try FileWatcher(path: resolvedPath, queue: queue, interval: 0.2)
            
            self.resetSpinner()
            
            try watcher.start(closure: {
                self.currentSpinner?.stop(text: "Changed!")
                watcher.stop()
                runner.startTest()
                semaphore.signal()
            })
            semaphore.wait()
        }
    }
    
    private func resetSpinner() {
        self.currentSpinner?.stopAndClear()
        self.currentSpinner = Spinner(pattern: .dots, text: "Observing for changes in \(self.path) (Press ^C to cancel)")
        self.currentSpinner?.start()
    }
    
}

extension MainLoop: TestRunnerDelegate {
    func testsSuccessful() {
        self.currentSpinner?.succeed(text: "Tests successful!")
        resetSpinner()
    }
    
    func testsFailed() {
        self.currentSpinner?.fail(text: "Tests failed :(")
        resetSpinner()
    }
}
