//
//  LDLARadioTests.swift
//  LDLARadioTests
//
//  Created by fox on 10/07/2019.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import XCTest
import Groot
import CoreData

class LDLARadioTests: XCTestCase {

    var store: GRTManagedStore?
    var context: NSManagedObjectContext?

    override func setUp() {
        super.setUp()
        
        store = try? GRTManagedStore(model: NSManagedObjectModel.testModelForUser)
        context = store?.context(with: .mainQueueConcurrencyType)
    }
    
    override func tearDown() {
        store = nil
        context = nil
        
        super.tearDown()
    }
    
    func testModelStreams() {
        guard let context = context else {
            XCTFail()
            return
        }
        
        func streamsJSON() -> JSONArray {
            return [
                [
                    "id": 1,
                    "name": "http://95.154.202.117:14142",
                    "url_type": "Stream",
                    "station_id": 1,
                    "head_is_working": false,
                    "listen_is_working": true,
                    "use_web": false,
                    "source_type": "",
                    "url": "http://adminradio.serveftp.com:35111/streams/1.json"
                ],
                [
                    "id": 2,
                    "name": "http://sa.mp3.icecast.magma.edge-access.net:7200/sc_rad30",
                    "url_type": "Stream",
                    "station_id": 4,
                    "head_is_working": false,
                    "listen_is_working": true,
                    "use_web": false,
                    "source_type": "audio/mpeg",
                    "url": "http://adminradio.serveftp.com:35111/streams/2.json"
                ],
                [
                    "id": 7,
                    "name": "http://200.58.118.108:8304/stream",
                    "url_type": "Stream",
                    "station_id": 6,
                    "head_is_working": false,
                    "listen_is_working": true,
                    "use_web": nil,
                    "source_type": nil,
                    "url": "http://adminradio.serveftp.com:35111/streams/7.json"
                ]
            ]
        }
        
        do {
            let streams: [Stream]  = try objects(fromJSONArray: streamsJSON(), inContext: context)
            
            XCTAssertEqual(3, streams.count)
            let stream = streams.last
            XCTAssert(stream != nil)
            XCTAssertNotNil(stream?.id)
            XCTAssertEqual(stream?.id, 7)
            XCTAssertEqual(stream?.name, "http://200.58.118.108:8304/stream")
        } catch {
            XCTFail("error: \(error)")
        }
    }

    
}

extension NSManagedObjectModel {
    
    static var testModelForUser: NSManagedObjectModel {
        let bundle = Bundle(for: LDLARadioTests.self)
        return NSManagedObjectModel.mergedModel(from: [bundle])!
    }
}
