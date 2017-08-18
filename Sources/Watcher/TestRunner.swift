//
//  TestRunner.swift
//  Watcher
//
//  Created by Benjamin Herzog on 18.08.17.
//

import Foundation

protocol TestRunnerDelegate: class {
    func testsFailed()
    func testsSuccessful()
}

class TestRunner: NSObject {
    
    let path: String
    weak var delegate: TestRunnerDelegate?
    private var running = false
    
    init(delegate: TestRunnerDelegate, path: String) {
        self.path = path
        self.delegate = delegate
    }
    
    func startTest() {
        self.running = true
        let res = runShell("swift test --package-path \(path) --parallel")
        let status = res.code
        status > 0 ? self.delegate?.testsFailed() : self.delegate?.testsSuccessful()
        self.running = false
    }
    
}
