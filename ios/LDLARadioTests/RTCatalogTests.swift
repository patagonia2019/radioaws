//
//  RTCatalogTests.swift
//  LDLARadioTests
//
//  Created by fox on 14/07/2019.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import XCTest
import CoreData
import JFCore
import Groot

@testable import LDLARadio

class RTCatalogTests: BaseTests {
    
    /// Unit test for Catalog, it requests all the information of catalog
    
    func testModelCatalog() {
        let expect = expectation(description: "catalog")
        RestApi.instance.requestRT(type: RTCatalog.self) { (error, catalog) in
            XCTAssertNil(error)
            XCTAssertNotNil(catalog)
            XCTAssertEqual(catalog?.title, "Navegar")
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
        
        let section = catalog?.sections?.allObjects.first as? RTCatalog
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
        
        let subsection = section?.sections?.allObjects.first as? RTCatalog
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
            XCTAssertNotNil(subsection?.sections?.allObjects.first)
            guard let sectionChannel = subsection?.sections?.allObjects.first as? RTCatalog else {
                XCTFail()
                return
            }
            XCTAssertNotNil(sectionChannel.channels)
            XCTAssertTrue(sectionChannel.channels?.count ?? 0 > 0)
            XCTAssertNotNil(sectionChannel.channels?.allObjects.first)
            guard let channel = sectionChannel.channels?.allObjects.first as? RTChannel else {
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

}

