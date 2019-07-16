//
//  RNATests.swift
//  LDLARadioTests
//
//  Created by fox on 16/07/2019.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import XCTest
import Groot

class RNATests: BaseTests {

    func testModelEmisoras() {
        guard let context = context else {
            XCTFail()
            return
        }
        
        do {
            let dial: RNADial = try object(withEntityName: "RNADial", fromJSONDictionary: emisorasJSON(), inContext: context) as! RNADial
//            let dial: RNADial = try object(fromJSONDictionary: emisorasJSON()["data"], inContext:  context)
//            let stations : [RNAStation] = try objects(withEntityName: "RNAStation", fromJSONArray: emisorasJSON()["data"] as! JSONArray, inContext: context) as! [RNAStation]
//            let stations : RNAStation = try objects(fromJSONArray: emisorasJSON()["data"] as! JSONArray, inContext: context)
//            XCTAssertNotNil(stations)

            XCTAssertNotNil(dial)
            XCTAssertEqual(dial.stations?.count, 2)
            let order = [NSSortDescriptor.init(key: "lastName", ascending: true)]
            guard let station = dial.stations?.sortedArray(using: order).first as? RNAStation else {
                XCTFail()
                return
            }
            XCTAssertEqual(station.lastName, "Buenos Aires")
        } catch {
            XCTFail("error: \(error)")
        }
    }

    func testRequestModelEmisoras() {
        let expect = expectation(description: "rna")
        RestApi.instance.requestRNA(usingQuery: "/listar_emisoras.json", type: RNADial.self) { (error, dial) in
            
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
