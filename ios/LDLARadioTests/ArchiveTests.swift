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

    func testModelArchiveOrgMeta() {
        guard let context = context else {
            XCTFail()
            return
        }

        do {
            let meta: ArchiveMeta = try object(withEntityName: "ArchiveMeta", fromJSONDictionary: archiveOrgMetaJSON(), inContext: context) as! ArchiveMeta

            XCTAssertNotNil(meta)
            XCTAssertEqual(meta.response?.docs?.count, 1)
            guard let doc = meta.response?.docs?.firstObject as? ArchiveDoc else {
                XCTFail()
                return
            }
            XCTAssertEqual(doc.title, "AudioBook 5 Harry Potter")

        } catch {
            XCTFail("error: \(error)")
        }
    }

    func testModelArchiveOrgMetaCrashJson() {
        guard let context = context else {
            XCTFail()
            return
        }

        do {
            guard let path = Bundle.main.path(forResource: "ArchiveOrgMetaCrash", ofType: "json") else {
                XCTFail()
                return
            }

            guard let data = fileJSON(path: path) else {
                XCTFail()
                return
            }
//            guard let str = String(data: data0, encoding: .utf16),
//                let data = Data.init(base64Encoded: str, options: .ignoreUnknownCharacters) else {
//                    XCTFail()
//                    return
//            }
////            let str = String(UTF8String: strToDecode.cStringUsingEncoding(NSUTF8StringEncoding))

            let metas: [ArchiveMeta] = try objects(fromJSONData: data, inContext: context)

            XCTAssertNotNil(metas)
            let meta = metas.first
            XCTAssertNotNil(meta)
            XCTAssertEqual(meta?.header?.qTime, 501)
            let response = meta?.response
            XCTAssertNotNil(response)
            XCTAssertEqual(response?.numFound, 37)
            let docs = response?.docs
            XCTAssertEqual(docs?.count, 35)
            let doc = docs?.firstObject as? ArchiveDoc
            XCTAssertNotNil(doc)
            XCTAssertEqual(doc?.title, "Hardcore Vinyl Collection 78GB")
            XCTAssertEqual(doc?.subject, "hardcore, techno, vinyl")
            let another = docs?.lastObject as? ArchiveDoc
            XCTAssertNotNil(another)
            XCTAssertEqual(another?.title, "Parc Crecelius 2019-07-27")

        } catch {
            XCTFail("error: \(error)")
        }
    }

    func testModelArchiveOrgMetaJson() {
        guard let context = context else {
            XCTFail()
            return
        }

        do {
            guard let path = Bundle.main.path(forResource: "ArchiveOrgMeta", ofType: "json") else {
                XCTFail()
                return
            }

            guard let data = fileJSON(path: path) else {
                XCTFail()
                return
            }
            let metas: [ArchiveMeta] = try objects(fromJSONData: data, inContext: context)

            XCTAssertNotNil(metas)
            let meta = metas.first
            XCTAssertNotNil(meta)
            XCTAssertEqual(meta?.header?.qTime, 33)
            let response = meta?.response
            XCTAssertNotNil(response)
            XCTAssertEqual(response?.numFound, 124)
            let docs = response?.docs
            XCTAssertEqual(docs?.count, 50)
            let doc = docs?.firstObject as? ArchiveDoc
            XCTAssertNotNil(doc)
            XCTAssertEqual(doc?.title, "AudioBook 5 Harry Potter")
            if let subject = doc?.subject {
                XCTAssertEqual(subject, "Harry Potter")
            } else {
                XCTFail()
            }
            let another = docs?.lastObject as? ArchiveDoc
            XCTAssertNotNil(another)
            XCTAssertEqual(another?.title, "The Dark Prophecy The Trials Of Apollo 2 Audiobook Part 1.3 GP")
            if let subject = another?.subject {
                XCTAssertEqual(subject, "khong gia dinh, khong gia dinh audiobook, taudio")
            } else {
                XCTFail()
            }

        } catch {
            XCTFail("error: \(error)")
        }
    }

    func testRequestArchiveMeta() {
        let expect = expectation(description: "/advancedsearch.php?q=harry+potter+audiobook")
    RestApi.instance.requestARCH(usingQuery: "/advancedsearch.php?q=collection:(oldtimeradio)+AND+mediatype:(audio)&fl[]=creator&fl[]=description&fl[]=downloads&fl[]=identifier&fl[]=item_size&fl[]=mediatype&fl[]=publicdate&fl[]=subject&fl[]=title&fl[]=type&sort[]=downloads+desc&sort[]=&sort[]=&rows=10&page=1", type: ArchiveMeta.self) { _, meta in

            XCTAssertNotNil(meta)
            let response = meta?.response
            XCTAssertNotNil(response)
            XCTAssertEqual(response?.numFound, 4173)
            let docs = response?.docs
            XCTAssertEqual(docs?.count, 10)
            let doc = docs?.firstObject as? ArchiveDoc
            XCTAssertNotNil(doc)
            XCTAssertEqual(doc?.title, "Gunsmoke - Single Episodes")
            XCTAssertEqual(doc?.subject, "OTRR, Old Time Radio Researchers Group, Old Time Radio, OTRR Single Episodes, Gunsmoke, OTRR - 2006-12")
            let another = docs?.lastObject as? ArchiveDoc
            XCTAssertNotNil(another)
            XCTAssertEqual(another?.title, "X Minus One - Single Episodes")
            expect.fulfill()
        }
        waitForExpectations(timeout: RestApi.Constants.Service.timeout, handler: { (error) in
            XCTAssertNil(error)
        })

    }

    func testModelArchiveOrgDetail() {
        guard let context = context else {
            XCTFail()
            return
        }

        do {
            let detail: ArchiveDetail = try object(withEntityName: "ArchiveDetail", fromJSONDictionary: archiveOrgDetailJSON(), inContext: context) as! ArchiveDetail

            XCTAssertNotNil(detail)
            XCTAssertEqual(detail.files?.count, 2)
            if let files = detail.files {
                for (k, v) in files {
                    let arcFile = try object(withEntityName: "ArchiveFile", fromJSONDictionary: v as! JSONDictionary, inContext: context) as? ArchiveFile
                    XCTAssertNotNil(arcFile)
                    arcFile?.original = k as? String
                    XCTAssertEqual(arcFile?.original, k as? String)
                }
            } else {
                XCTFail()
            }
        } catch {
            XCTFail("error: \(error)")
        }
    }

    func testModelArchiveOrgDetailJson() {
        guard let context = context else {
            XCTFail()
            return
        }

        do {
            guard let path = Bundle.main.path(forResource: "ArchiveOrgDetail", ofType: "json") else {
                XCTFail()
                return
            }

            guard let data = fileJSON(path: path) else {
                XCTFail()
                return
            }
            let details: [ArchiveDetail] = try objects(fromJSONData: data, inContext: context)

            XCTAssertNotNil(details)
            let detail = details.first
            XCTAssertNotNil(detail)
        } catch {
            XCTFail("error: \(error)")
        }
    }

    func testRequestArchiveOrgDetailHarry() {
        guard let context = context else {
            XCTFail()
            return
        }

        let expect = expectation(description: "/details/Book5HarryPotter")
        RestApi.instance.requestARCH(usingQuery: "/details/Book5HarryPotter", type: ArchiveDetail.self) { _, detail in

            XCTAssertNotNil(detail)
            XCTAssertEqual(detail?.server, "ia800102.us.archive.org")
            XCTAssertEqual(detail?.dir, "/23/items/Book5HarryPotter")
            if let files = detail?.files {
                for (k, v) in files {
                    let arcFile = try? object(withEntityName: "ArchiveFile", fromJSONDictionary: v as! JSONDictionary, inContext: context) as? ArchiveFile
                    XCTAssertNotNil(arcFile)
                    arcFile?.original = k as? String
                    XCTAssertEqual(arcFile?.original, k as? String)
                    if arcFile?.format == "VBR MP3" && arcFile?.track == "02" {
                        XCTAssertEqual(arcFile?.original, "/AudioBook5 parte 2.mp3")
                    }
                }
            } else {
                XCTFail()
            }

            expect.fulfill()
        }
        waitForExpectations(timeout: RestApi.Constants.Service.timeout, handler: { (error) in
            XCTAssertNil(error)
        })

    }

    func testRequestArchiveOrgDetailAlice() {
        guard let context = context else {
            XCTFail()
            return
        }

        let expect = expectation(description: "/details/alice_in_wonderland_librivox")
        RestApi.instance.requestARCH(usingQuery: "/details/alice_in_wonderland_librivox", type: ArchiveDetail.self) { _, detail in

            XCTAssertNotNil(detail)
            XCTAssertEqual(detail?.dir, "/8/items/alice_in_wonderland_librivox")
            if let files = detail?.files {
                for (k, v) in files {
                    let arcFile = try? object(withEntityName: "ArchiveFile", fromJSONDictionary: v as! JSONDictionary, inContext: context) as? ArchiveFile
                    XCTAssertNotNil(arcFile)
                    arcFile?.original = k as? String
                    XCTAssertEqual(arcFile?.original, k as? String)
                    if arcFile?.format == "64Kbps MP3 ZIP" {
                        XCTAssertEqual(arcFile?.original, "/alice_in_wonderland_librivox_64kb_mp3.zip")
                    }
                }
            } else {
                XCTFail()
            }

            expect.fulfill()
        }
        waitForExpectations(timeout: RestApi.Constants.Service.timeout, handler: { (error) in
            XCTAssertNil(error)
        })

    }

    func testRequestModelFiles() {
        let expect = expectation(description: "/details/23/items/Book5HarryPotter/files")
        RestApi.instance.requestARCH(usingQuery: "/details/23/items/Book5HarryPotter/files", type: ArchiveDetail.self) { error, detail in

            XCTAssertNil(error)
            XCTAssertNotNil(detail)
            expect.fulfill()
        }
        waitForExpectations(timeout: RestApi.Constants.Service.timeout, handler: { (error) in
            XCTAssertNil(error)
        })

    }

}
