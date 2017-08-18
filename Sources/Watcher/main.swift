//
//  main.swift
//  Watcher
//
//  Created by Benjamin Herzog on 18.08.17.
//

import Foundation
import FileWatcher
import CLISpinner

extension Array {
    var second: Element? {
        guard count > 1 else { return nil }
        return self[1]
    }
}

let givenPath = CommandLine.arguments.second ?? fileManager.currentDirectoryPath

let resolvedPath = URL(fileURLWithPath: givenPath).path


func startMainLoop(path: String) throws {
    
    while true {
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "yeah", qos: DispatchQoS.background, attributes: [.concurrent])
        
        let watcher = try Watcher(path: resolvedPath, queue: queue, interval: 0.2)
        
        let spinner = Spinner(pattern: .dots, text: "Start observing in \(resolvedPath) (Press ^C to cancel)")
        spinner.start()
        
        try watcher.start(closure: {
            spinner.stop(text: "Changed!")
            watcher.stop()
            semaphore.signal()
        })
        semaphore.wait()
    }
    
}

do {
    try startMainLoop(path: resolvedPath)
} catch {
    print("ERROR: \(error)")
}
