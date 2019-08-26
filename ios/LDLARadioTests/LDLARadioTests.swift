//
//  LDLARadioTests.swift
//  LDLARadioTests
//
//  Created by fox on 10/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import XCTest
import Groot
import CoreData

class LDLARadioTests: BaseTests {

    func testModelStreams() {
        guard let context = context else {
            XCTFail()
            return
        }

        do {
            let streams: [Stream]  = try objects(fromJSONArray: streamsJSON(), inContext: context)

            XCTAssertEqual(3, streams.count)
            let stream = streams.last
            XCTAssert(stream != nil)
            XCTAssertNotNil(stream?.id)
            XCTAssertEqual(stream?.id, 7)
            XCTAssertEqual(stream?.url, "http://200.58.118.108:8304/stream")
        } catch {
            XCTFail("error: \(error)")
        }
    }
}
