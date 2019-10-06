//
//  SomeOtherTimeTests.swift
//  LDLARadioTests
//
//  Created by fox on 06/10/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import XCTest

class SomeOtherTimeTests: XCTestCase {
    
    private func timeStringFor(seconds: Float) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour]
        formatter.zeroFormattingBehavior = .pad

        guard let output = formatter.string(from: TimeInterval(seconds)) else {
            return nil
        }
        if seconds < 3600 {
            guard let rng = output.range(of: ":") else { return nil }
            let ub = rng.upperBound
            let str = output[ub...]
            return String(str)
        }
        return output
    }

    func testTimeStrings() {
        let str = timeStringFor(seconds: 33)
        XCTAssertEqual(str, "00:33")
        let str1 = timeStringFor(seconds: 960)
        XCTAssertEqual(str1, "16:00")
        let str2 = timeStringFor(seconds: 9600)
        XCTAssertEqual(str2, "02:40:00")
    }
    
}
