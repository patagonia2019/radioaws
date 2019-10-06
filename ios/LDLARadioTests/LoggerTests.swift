//
//  LoggerTests.swift
//  LDLARadioTests
//
//  Created by fox on 06/10/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import XCTest
@testable import LDLARadio

class LoggerTests: XCTestCase {

    func testLog() {
        let str = String(format: "debug M1 %d, %@", 1, "abc")
        Log.debug("%@", str)
        Log.debug("debug %d, %@", 1, "abc")
        Log.debug("%@", "debug x3 \(1), \("abc")")
    }
}
