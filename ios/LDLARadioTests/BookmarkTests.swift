//
//  BookmarkTests.swift
//  LDLARadioTests
//
//  Created by fox on 24/07/2019.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import XCTest
import Groot
import CoreData

class BookmarkTests: BaseTests {

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
            XCTAssertEqual(stream?.name, "http://200.58.118.108:8304/stream")
            
            let audioViewModel = AudioViewModel(stream: stream)
            
            guard let entity = NSEntityDescription.entity(forEntityName: "Bookmark", in: context) else {
                XCTFail()
                return
            }
            if var bookmark = NSManagedObject(entity: entity, insertInto: context) as? Bookmark {
                bookmark += audioViewModel
                XCTAssertEqual(bookmark.id, audioViewModel.id)
                XCTAssertEqual(bookmark.id, "7")
                XCTAssertEqual(bookmark.url, audioViewModel.url?.absoluteString)
            }
            else {
                XCTFail()
            }

            
        } catch {
            XCTFail("error: \(error)")
        }
    }

}
