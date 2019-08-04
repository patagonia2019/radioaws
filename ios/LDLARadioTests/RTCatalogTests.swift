//
//  RTCatalogTests.swift
//  LDLARadioTests
//
//  Created by fox on 14/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import XCTest
import CoreData
import JFCore
import Groot

@testable import LDLARadio

class RTCatalogTests: BaseTests {
    
    
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

    func testModelAudioOne() {
        guard let context = context else {
            XCTFail()
            return
        }
        
        do {
            let audio = audio1JSON()
            if audio.keys.contains("body"),
                let body = audio["body"] as? JSONDictionary {
                let audio: RTCatalog = try object(fromJSONDictionary: body, inContext: context)
                XCTAssertNotNil(audio)
            }
            else {
                let audio: RTCatalog = try object(fromJSONDictionary: audio1JSON(), inContext: context)
                XCTAssertNotNil(audio)
            }
        } catch {
            XCTFail("error: \(error)")
        }
    }

    /// Unit test for Catalog, it requests all the information of catalog
    
    func testModelCatalog() {
        let expect = expectation(description: "catalog")
        RestApi.instance.requestRT(type: RTCatalog.self) { (error, catalog) in
            XCTAssertNil(error)
            XCTAssertNotNil(catalog)
            XCTAssertEqual(catalog?.title, "Browse")
            XCTAssertEqual(catalog?.sections?.count, 7)
            expect.fulfill()
        }
        waitForExpectations(timeout: RestApi.Constants.Service.timeout, handler: { (error) in
            XCTAssertNil(error)
        })
    }

    /// Unit test for Section, it requests all the information of section
    func testModelSection() {
        
        guard let context = context else {
            XCTFail()
            return
        }
        var catalog: RTCatalog? = nil
        do {
            catalog = try object(fromJSONDictionary: catalogJSON(), inContext: context)
        } catch {
            XCTFail("error: \(error)")
        }
        
        XCTAssertNotNil(catalog)
        XCTAssertEqual(catalog?.title, "Browse")
        XCTAssertEqual(catalog?.sections?.count, 2)
        
        let section = catalog?.sections?.array.first as? RTCatalog
        XCTAssertNotNil(section)
        XCTAssertNotNil(section?.text)
        
        guard let url = section?.url else {
            XCTFail()
            return
        }
        let expectSection = self.expectation(description: "section")
        RestApi.instance.requestRT(usingUrl: url, type: RTCatalog.self) { (error, section2) in
            XCTAssertNil(error)
            XCTAssertNotNil(section2)
            section?.sections = section2?.sections
            section?.title = section2?.title
            expectSection.fulfill()
        }
        
        waitForExpectations(timeout: RestApi.Constants.Service.timeout, handler: { (error) in
            XCTAssertNil(error)
        })
    }
    
    /// Unit test for Stations, it requests all the information of station
    func testModelStations() {
        
        guard let context = context else {
            XCTFail()
            return
        }
        var section: RTCatalog? = nil
        do {
            section = try object(fromJSONDictionary: sectionJSON(), inContext: context)
        } catch {
            XCTFail("error: \(error)")
        }
        
        XCTAssertNotNil(section)
        XCTAssertEqual(section?.title, "Music")
        XCTAssertEqual(section?.sections?.count, 2)
        
        let subsection = section?.sections?.array.first as? RTCatalog
        XCTAssertNotNil(subsection)
        XCTAssertNotNil(subsection?.text)

        guard let url = subsection?.url else {
            XCTFail()
            return
        }
        let expectSection = self.expectation(description: "subsection")
        RestApi.instance.requestRT(usingUrl: url, type: RTCatalog.self) { (error, subsection2) in
            XCTAssertNil(error)
            XCTAssertNotNil(subsection2)
            subsection?.sections = subsection2?.sections
            subsection?.title = subsection2?.title
            XCTAssertNotNil(subsection?.sections?.first)
            guard let sectionChannel = subsection?.sections?.array.first as? RTCatalog else {
                XCTFail()
                return
            }
            XCTAssertNotNil(sectionChannel.audios)
            XCTAssertTrue(sectionChannel.audios?.count ?? 0 > 0)
            XCTAssertNotNil(sectionChannel.audios?.array.first)
            guard let channel = sectionChannel.audios?.array.first as? RTCatalog else {
                XCTFail()
                return
            }
            XCTAssertNotNil(channel.image)

            expectSection.fulfill()
        }

        waitForExpectations(timeout: RestApi.Constants.Service.timeout, handler: { (error) in
            XCTAssertNil(error)
        })
    }
    
    func testSomeCrash() {
        guard let context = context else {
            XCTFail()
            return
        }
        var catalog: RTCatalog? = nil
        do {
            catalog = try object(fromJSONDictionary: someCrashJSON(), inContext: context)
        } catch {
            XCTFail("error: \(error)")
        }
        XCTAssertNotNil(catalog)
        
    }
    
    func testNavegar() {
        guard let context = context else {
            XCTFail()
            return
        }
        var catalog: RTCatalog? = nil
        do {
            catalog = try object(fromJSONDictionary: navegarJSON(), inContext: context)
        } catch {
            XCTFail("error: \(error)")
        }
        XCTAssertNotNil(catalog)

    }

}

