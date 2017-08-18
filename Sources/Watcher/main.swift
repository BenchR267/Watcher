//
//  main.swift
//  Watcher
//
//  Created by Benjamin Herzog on 18.08.17.
//

import Foundation

let givenPath = CommandLine.arguments.second ?? fileManager.currentDirectoryPath

let resolvedPath = URL(fileURLWithPath: givenPath).path

do {
    let loop = MainLoop(path: resolvedPath)
    try loop.start()
} catch {
    print("ERROR: \(error)")
}
