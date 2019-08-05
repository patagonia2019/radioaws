//
//  RNAController.swift
//  LDLARadio
//
//  Created by fox on 23/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import JFCore

class RNAController: BaseController {
    
    private var amModels = [AudioViewModel]()
    private var fmModels = [AudioViewModel]()

    override init() { }
    
    init(withStreams dial: RNADial?) {
        super.init()
        self.updateModels(dial: dial)
    }
    
    override func numberOfSections() -> Int {
        return 2
    }
    
    override func titleForHeader(inSection section: Int) -> String? {
        if section == 0 {
            return "AM"
        }
        return "FM"
    }
    
    override func numberOfRows(inSection section: Int) -> Int {
        let count : Int = (section == 0) ? amModels.count : fmModels.count
        return count > 0 ? count : 1
    }
    
    override func model(forSection section: Int, row: Int) -> Any? {
        if section == 0 {
            if row < amModels.count {
                return amModels[row]
            }
        }
        if row < fmModels.count {
            return fmModels[row]
        }
        return nil
    }
    
    override func heightForRow(at section: Int, row: Int) -> CGFloat {
        return CGFloat(AudioViewModel.cellheight)
    }
    
    override func prompt() -> String {
        return "Radio Nacional Argentina"
    }
    
    private func updateModels(dial: RNADial?) {
        guard let dial = dial else {
            return
        }
        lastUpdated = dial.updatedAt
        
        amModels = dial.stations?.filtered(using: NSPredicate(format: "amUri.length > 0")).map({ AudioViewModel(stationAm: $0 as? RNAStation) }) ?? [AudioViewModel]()
        fmModels = dial.stations?.filtered(using: NSPredicate(format: "fmUri.length > 0")).map({ AudioViewModel(stationFm: $0 as? RNAStation) }) ?? [AudioViewModel]()
    }

    private func updateModels() {
        guard let dial = RNADial.all()?.first else {
            return
        }
        return updateModels(dial: dial)

    }

    override func privateRefresh(isClean: Bool = false,
                                 prompt: String = "Radio Nacional Argentina",
                                 finishClosure: ((_ error: JFError?) -> Void)? = nil)
    {
                
        if isClean == false {
            updateModels()
            if fmModels.count > 0 && amModels.count > 0 {
                finishClosure?(nil)
                return
            }
        }
        
        RestApi.instance.context?.performAndWait {
            
            RNABand.clean()
            RNAProgram.clean()
            RNACurrentProgram.clean()
            RNAStation.clean()
            RNADial.clean()

            RestApi.instance.requestRNA(usingQuery: "/api/listar_emisoras.json", type: RNADial.self) { (error, dial) in
                if error != nil {
                    CoreDataManager.instance.rollback()
                } else {
                    self.updateModels()
                    CoreDataManager.instance.save()
                }
                finishClosure?(error)
            }
        }
    }
    
    func updateDial(finishClosure: ((_ error: Error?) -> Void)? = nil)
    {
        guard let dial = RNADial.all()?.first else {
            return
        }

        RestApi.instance.context?.performAndWait {

            guard let amStations = dial.stations?.filtered(using: NSPredicate(format: "amUri.length > 0")).array as? [RNAStation] else {
                self.updateModels()
                finishClosure?(nil)
                return
            }
            guard let fmStations = dial.stations?.filtered(using: NSPredicate(format: "fmUri.length > 0")).array as? [RNAStation] else {
                self.updateModels()
                finishClosure?(nil)
                return
            }

            var amStationsVar = [RNAStation]()
            amStationsVar.append(contentsOf: amStations)
            self.updateStations(stations: amStationsVar, isAm: true) { (error) in
                
                var fmStationsVar = [RNAStation]()
                fmStationsVar.append(contentsOf: fmStations)
                self.updateStations(stations: fmStationsVar, isAm: false) { (error) in
                    self.updateModels()
                    finishClosure?(error)
                }
            }
        }

    }
    
    private func updateStations(stations: [RNAStation],
                              isAm: Bool = false,
                              finishClosure: ((_ error: Error?) -> Void)? = nil)
    {
        if stations.count == 0 {
            finishClosure?(nil)
            return
        }
        var stationsToUpdate = [RNAStation]()
        stationsToUpdate.append(contentsOf: stations)
        
        let station = stationsToUpdate.popLast()
        
        updateProgram(forStation: station, isAm: isAm) { (error) in
            self.updateBand(forStation: station, isAm: isAm) { error in
                self.updateStations(stations: stationsToUpdate, isAm: isAm, finishClosure: finishClosure)
            }
        }
    }
    
    
    private func updateProgram(forStation station: RNAStation?,
                               isAm: Bool = false,
                               finishClosure: ((_ error: Error?) -> Void)? = nil) {
        guard let stationId = station?.id else {
            finishClosure?(nil)
            return
        }
        var query : String = "/api/listar_programacion_actual/\(stationId)"
        if isAm {
            if station?.dialAM != nil {
                query += "/AM.json"
            }
            else {
                finishClosure?(nil)
            }
        }
        else if station?.dialFM != nil {
            query += "/FM.json"
        }
        else {
            finishClosure?(nil)
            return
        }
        RestApi.instance.requestRNA(usingQuery: query, type: RNACurrentProgram.self) { (error, program) in
            if isAm {
                station?.amCurrentProgram = program
            }
            else {
                station?.fmCurrentProgram = program
            }
            self.updateBand(forStation: station, isAm: isAm) { error in
                finishClosure?(error)
            }
        }
    }
    
    private func updateBand(forStation station: RNAStation?,
                               isAm: Bool = false,
                               finishClosure: ((_ error: Error?) -> Void)? = nil) {
        guard let stationId = station?.id else {
            finishClosure?(nil)
            return
        }
        var query : String = "/api/listar_programacion_diaria_banda/\(stationId)"
        if isAm {
            if station?.dialAM != nil {
                query += "/AM.json"
            }
            else {
                finishClosure?(nil)
            }
        }
        else if station?.dialFM != nil {
            query += "/FM.json"
        }
        else {
            finishClosure?(nil)
            return
        }
        RestApi.instance.requestRNA(usingQuery: query, type: RNABand.self) { (error, band) in
            if isAm {
                station?.amBand = band
            }
            else {
                station?.fmBand = band
            }
            finishClosure?(error)
        }
    }

}
