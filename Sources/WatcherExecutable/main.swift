//
//  main.swift
//  Watcher
//
//  Created by Benjamin Herzog on 18.08.17.
//

import Foundation
import FileWatcher

extension Array {
    var second: Element? {
        guard count > 1 else { return nil }
        return self[1]
    }
}

let path = CommandLine.arguments.second ?? fileManager.currentDirectoryPath

let url = URL(fileURLWithPath: path)

let semaphore = DispatchSemaphore(value: 0)
let queue = DispatchQueue(label: "yeah", qos: DispatchQoS.background, attributes: [.concurrent])

let watcher = try Watcher(path: url.path, queue: queue, interval: 1)
try watcher.start(closure: {
    print("Changed!")
})
semaphore.wait()
