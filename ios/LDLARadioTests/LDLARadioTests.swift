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
    
    func testModelBrowse() {
        guard let context = context else {
            XCTFail()
            return
        }
        
        do {
            let catalog: RTCatalog = try object(fromJSONDictionary: catalogJSON(), inContext: context)
            XCTAssertNotNil(catalog)
            XCTAssertEqual(catalog.title, "Browse")
            XCTAssertEqual(catalog.sections?.count, 2)
            let section = catalog.sections?.first(where: { (section) -> Bool in
                return (section as? RTCatalog)?.text == "Music"
            }) as? RTCatalog
            XCTAssertNotNil(section)
            XCTAssertEqual(section?.url, "http://opml.radiotime.com/Browse.ashx?c=music")

        } catch {
            XCTFail("error: \(error)")
        }
    }

    func testModelMusic() {
        guard let context = context else {
            XCTFail()
            return
        }
        
        
        do {
            let guide: RTCatalog = try object(fromJSONDictionary: sectionJSON(), inContext: context)
            XCTAssertNotNil(guide)
            XCTAssertEqual(guide.title, "Music")
            XCTAssertEqual(guide.sections?.count, 2)
            let section = guide.sections?.first(where: { (theme) -> Bool in
                return (theme as? RTCatalog)?.text == "50's"
            }) as? RTCatalog
            XCTAssertNotNil(section)
            XCTAssertEqual(section?.url, "http://opml.radiotime.com/Browse.ashx?id=g390")
            
        } catch {
            XCTFail("error: \(error)")
        }
    }
    
    func testModelMusic00() {
        guard let context = context else {
            XCTFail()
            return
        }
        
        do {
            let guide: RTCatalog = try object(fromJSONDictionary: stationsJSON(), inContext: context)
            XCTAssertNotNil(guide)
            XCTAssertEqual(guide.title, "00's")
            XCTAssertEqual(guide.sections?.count, 2)
            
            let outline = guide.sections?.first(where: { (section) -> Bool in
                return (section as? RTCatalog)?.key == "stations"
            }) as? RTCatalog
            XCTAssertNotNil(outline)
            XCTAssertEqual(outline?.text, "Stations")
            
            let channel = outline?.audios?.array.first(where: { (c) -> Bool in
                return (c as? RTCatalog)?.presetId == "s216185"
            }) as? RTCatalog
            XCTAssertNotNil(channel)
            XCTAssertEqual(channel?.image, "http://cdn-radiotime-logos.tunein.com/s216185q.png")
            
        } catch {
            XCTFail("error: \(error)")
        }
    }

    func testModelMusicOne() {
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
            
        } catch {
            XCTFail("error: \(error)")
        }
    }
}
