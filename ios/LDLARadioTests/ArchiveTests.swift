//
//  ArchiveTests.swift
//  LDLARadioTests
//
//  Created by fox on 05/08/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import XCTest
import Groot

class ArchiveTests: BaseTests {
    
    func testRequestModelAudios() {
        let expect = expectation(description: "services/collection-rss.php?mediatype=audio")
        RestApi.instance.requestRNA(usingQuery: "/services/collection-rss.php?mediatype=audio", type: RNADial.self) { (error, dial) in
            
            XCTAssertNil(error)
            XCTAssertNotNil(dial)
            XCTAssertNotNil(dial?.objectID)
            XCTAssertEqual(dial?.stations?.count, 54)
            let order = [NSSortDescriptor.init(key: "lastName", ascending: true)]
            guard let station = dial?.stations?.sortedArray(using: order).first as? RNAStation else {
                XCTFail()
                return
            }
            XCTAssertEqual(station.lastName, "Argentina al mundo")
            
            expect.fulfill()
        }
        waitForExpectations(timeout: RestApi.Constants.Service.timeout, handler: { (error) in
            XCTAssertNil(error)
        })
        
    }
    
}
