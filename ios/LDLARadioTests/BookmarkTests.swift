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
            XCTAssertEqual(stream?.url, "http://200.58.118.108:8304/stream")
            
            let audioViewModel = AudioViewModel(stream: stream)
            
            if var bookmark = Bookmark.create() {
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

    func testModelMusic1() {
        guard let context = context else {
            XCTFail()
            return
        }
        
        do {
            let guide: RTCatalog = try object(fromJSONDictionary: station1JSON(), inContext: context)
            XCTAssertNotNil(guide)
            XCTAssertEqual(guide.title, "Chon Mix Stations - 2h, 34m left")
            XCTAssertEqual(guide.sections?.count, 1)
            
            let audio = guide.sections?.firstObject as? RTCatalog
            XCTAssertNotNil(audio)
            XCTAssertEqual(audio?.type, "audio")
            XCTAssertTrue(audio?.isAudio() ?? false)
            
            let audioViewModel = AudioViewModel(audio: audio)
            
            if var bookmark = Bookmark.create() {
                bookmark += audioViewModel
                XCTAssertEqual(bookmark.id, audioViewModel.id)
                XCTAssertEqual(bookmark.url, audioViewModel.url?.absoluteString)
            }
            else {
                XCTFail()
            }
        
            
        } catch {
            XCTFail("error: \(error)")
        }
    }
    
    
    func testModelMusic2() {
        guard let context = context else {
            XCTFail()
            return
        }
        
        do {
            let guide: RTCatalog = try object(fromJSONDictionary: station1JSON(), inContext: context)
            XCTAssertNotNil(guide)
            XCTAssertEqual(guide.title, "Chon Mix Stations - 2h, 34m left")
            XCTAssertEqual(guide.sections?.count, 1)
            
            let audio = guide.sections?.firstObject as? RTCatalog
            XCTAssertNotNil(audio)
            XCTAssertEqual(audio?.type, "audio")
            XCTAssertTrue(audio?.isAudio() ?? false)
            
            audio?.subtext = nil
            audio?.bitrate = nil
            audio?.currentTrack = nil
            
            let audioViewModel2 = AudioViewModel(audio: audio)
            
            if var bookmark = Bookmark.create() {
                bookmark += audioViewModel2
                XCTAssertEqual(bookmark.id, audioViewModel2.id)
                XCTAssertEqual(bookmark.url, audioViewModel2.url?.absoluteString)
            }
            else {
                XCTFail()
            }
            
        } catch {
            XCTFail("error: \(error)")
        }
    }

    func testModelMusic3() {
        guard let context = context else {
            XCTFail()
            return
        }
        
        do {
            let guide: RTCatalog = try object(fromJSONDictionary: station1JSON(), inContext: context)
            XCTAssertNotNil(guide)
            XCTAssertEqual(guide.title, "Chon Mix Stations - 2h, 34m left")
            XCTAssertEqual(guide.sections?.count, 1)
            
            let audio = guide.sections?.firstObject as? RTCatalog
            XCTAssertNotNil(audio)
            XCTAssertEqual(audio?.type, "audio")
            XCTAssertTrue(audio?.isAudio() ?? false)
            
            audio?.title = nil
            let audioViewModel3 = AudioViewModel(audio: audio)
            
            if var bookmark = Bookmark.create() {
                bookmark += audioViewModel3
                XCTAssertEqual(bookmark.id, audioViewModel3.id)
                XCTAssertEqual(bookmark.url, audioViewModel3.url?.absoluteString)
            }
            else {
                XCTFail()
            }
            
        } catch {
            XCTFail("error: \(error)")
        }
    }

    func testModelMusic4() {
        guard let context = context else {
            XCTFail()
            return
        }
        
        do {
            let guide: RTCatalog = try object(fromJSONDictionary: station1JSON(), inContext: context)
            XCTAssertNotNil(guide)
            XCTAssertEqual(guide.title, "Chon Mix Stations - 2h, 34m left")
            XCTAssertEqual(guide.sections?.count, 1)
            
            let audio = guide.sections?.firstObject as? RTCatalog
            XCTAssertNotNil(audio)
            XCTAssertEqual(audio?.type, "audio")
            XCTAssertTrue(audio?.isAudio() ?? false)
            
            audio?.subtext = nil
            let audioViewModel4 = AudioViewModel(audio: audio)
            
            if var bookmark = Bookmark.create() {
                bookmark += audioViewModel4
                XCTAssertEqual(bookmark.id, audioViewModel4.id)
                XCTAssertEqual(bookmark.url, audioViewModel4.url?.absoluteString)
            }
            else {
                XCTFail()
            }
            
        } catch {
            XCTFail("error: \(error)")
        }
    }
    

}
