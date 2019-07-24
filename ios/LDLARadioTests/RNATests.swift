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
            let dial: RNADial = try object(withEntityName: "RNADial", fromJSONDictionary: rnaEmisorasJSON(), inContext: context) as! RNADial

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
        let expect = expectation(description: "api/listar_emisoras")
        RestApi.instance.requestRNA(usingQuery: "/api/listar_emisoras.json", type: RNADial.self) { (error, dial) in
            
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

    func testModelProgram() {

        guard let context = context else {
            XCTFail()
            return
        }
        
        do {
            let program: RNACurrentProgram = try object(withEntityName: "RNACurrentProgram", fromJSONDictionary: RNACurrentProgramJSON(), inContext: context) as! RNACurrentProgram
            
            XCTAssertNotNil(program)
            XCTAssertEqual(program.name, "LRA 30 Radio Nacional San Carlos de Bariloche")
            XCTAssertEqual(program.programName, "La radio de todos")
        } catch {
            XCTFail("error: \(error)")
        }
    }

    func testRequestModelProgram() {
        let expect = expectation(description: "listar_programacion_actual")
        RestApi.instance.requestRNA(usingQuery: "/api/listar_programacion_actual/34/AM.json", type: RNACurrentProgram.self) { (error, program) in
            
            XCTAssertNil(error)
            XCTAssertNotNil(program)
            XCTAssertEqual(program?.name, "LRA 30 Radio Nacional San Carlos de Bariloche")
            XCTAssertEqual(program?.programName, "La radio de todos")

            expect.fulfill()
        }
        waitForExpectations(timeout: RestApi.Constants.Service.timeout, handler: { (error) in
            XCTAssertNil(error)
        })
    }
    
    func testModelDayPrograms() {
        guard let context = context else {
            XCTFail()
            return
        }
        do {
            let band: RNABand = try object(withEntityName: "RNABand", fromJSONDictionary: rnaDayProgramsJSON(), inContext: context) as! RNABand
            
            XCTAssertNotNil(band)
            XCTAssertEqual(band.programs?.count, 17)
            
            let program = band.programs?.first(where: { (program) -> Bool in
                return (program as? RNAProgram)?.name == "Sonia Ferraris"
            }) as? RNAProgram
            XCTAssertEqual(program?.reporter, "Trasnoche Nacional")

        } catch {
            XCTFail("error: \(error)")
        }
    }
    

    func testRequestModelDayPrograms() {
        let expect = expectation(description: "listar_programacion_diaria_banda")
        RestApi.instance.requestRNA(usingQuery: "/api/listar_programacion_diaria_banda/1/AM.json", type: RNABand.self) { (error, band) in
            
            XCTAssertNil(error)
            XCTAssertNotNil(band)
            XCTAssertEqual(band?.programs?.count, 17)
            
            let program = band?.programs?.first(where: { (program) -> Bool in
                return (program as? RNAProgram)?.name == "Sonia Ferraris"
            }) as? RNAProgram
            XCTAssertEqual(program?.reporter, "Trasnoche Nacional")

            expect.fulfill()
        }
        waitForExpectations(timeout: RestApi.Constants.Service.timeout, handler: { (error) in
            XCTAssertNil(error)
        })
    }

}
