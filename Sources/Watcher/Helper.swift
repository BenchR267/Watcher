//
//  Helper.swift
//  Watcher
//
//  Created by Benjamin Herzog on 18.08.17.
//

import Foundation

let fileManager = FileManager.default

extension Array {
    var second: Element? {
        guard count > 1 else { return nil }
        return self[1]
    }
}

func runShell(_ script: String) -> (code: Int32, out: String?, err: String?) {
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
    
    return (process.terminationStatus, outString, errString)
}
