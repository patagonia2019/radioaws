//
//  RNAController.swift
//  LDLARadio
//
//  Created by fox on 23/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation

class RNAController: BaseController {

    var amCatalogViewModel = SectionViewModel()
    var fmCatalogViewModel = SectionViewModel()

    private var amModels = [AudioViewModel]()
    private var fmModels = [AudioViewModel]()

    override init() {
        amCatalogViewModel.title.text = "AM"
        fmCatalogViewModel.title.text = "FM"
        amCatalogViewModel.audios = amModels
        fmCatalogViewModel.audios = fmModels
    }

    init(withStreams dial: RNADial?) {
        super.init()
        self.updateModels(dial: dial)
    }

    override func numberOfSections() -> Int {
        return 2
    }

    override func numberOfRows(inSection section: Int) -> Int {
        if section == 0 {
            if amCatalogViewModel.isCollapsed == true {
                return 0
            }
        } else {
            if fmCatalogViewModel.isCollapsed == true {
                return 0
            }
        }
        let rows: Int = (section == 0) ? amModels.count : fmModels.count
        return rows > 0 ? rows : 1
    }

    override func modelInstance(inSection section: Int) -> SectionViewModel? {
        if section == 0 {
            return amCatalogViewModel
        }
        return fmCatalogViewModel
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

    override func title() -> String {
        return "Radio Nacional Argentina"
    }

    private func updateModels(dial: RNADial?) {
        guard let dial = dial else {
            return
        }
        lastUpdated = dial.updatedAt

        amModels = dial.stations?.filtered(using: NSPredicate(format: "amUri.length > 0")).map({ AudioViewModel(station: $0 as? RNAStation, isAm: true) }) ?? [AudioViewModel]()
        fmModels = dial.stations?.filtered(using: NSPredicate(format: "fmUri.length > 0")).map({ AudioViewModel(station: $0 as? RNAStation, isAm: false) }) ?? [AudioViewModel]()
    }

    private func updateModels() {
        guard let dial = RNADial.all()?.first else {
            return
        }
        return updateModels(dial: dial)

    }

    override func privateRefresh(isClean: Bool = false,
                                 prompt: String = "Radio Nacional Argentina",
                                 finishClosure: ((_ error: NSError?) -> Void)? = nil) {

        if isClean == false {
            updateModels()
            if !fmModels.isEmpty && !amModels.isEmpty {
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

            RestApi.instance.requestRNA(usingQuery: "/api/listar_emisoras.json", type: RNADial.self) { (error, _) in
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

    func updateDial(finishClosure: ((_ error: Error?) -> Void)? = nil) {
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
                                finishClosure: ((_ error: Error?) -> Void)? = nil) {
        if stations.isEmpty {
            finishClosure?(nil)
            return
        }
        var stationsToUpdate = [RNAStation]()
        stationsToUpdate.append(contentsOf: stations)

        let station = stationsToUpdate.popLast()

        updateProgram(forStation: station, isAm: isAm) { (_) in
            self.updateBand(forStation: station, isAm: isAm) { _ in
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
        var query: String = "/api/listar_programacion_actual/\(stationId)"
        if isAm {
            if station?.dialAM != nil {
                query += "/AM.json"
            } else {
                finishClosure?(nil)
            }
        } else if station?.dialFM != nil {
            query += "/FM.json"
        } else {
            finishClosure?(nil)
            return
        }
        RestApi.instance.requestRNA(usingQuery: query, type: RNACurrentProgram.self) { (error, program) in
            if isAm {
                station?.amCurrentProgram = program
            } else {
                station?.fmCurrentProgram = program
            }
            self.updateBand(forStation: station, isAm: isAm) { error in
                DispatchQueue.main.sync {
                    finishClosure?(error)
                }
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
        var query: String = "/api/listar_programacion_diaria_banda/\(stationId)"
        if isAm {
            if station?.dialAM != nil {
                query += "/AM.json"
            } else {
                finishClosure?(nil)
            }
        } else if station?.dialFM != nil {
            query += "/FM.json"
        } else {
            finishClosure?(nil)
            return
        }
        RestApi.instance.requestRNA(usingQuery: query, type: RNABand.self) { (error, band) in
            if isAm {
                station?.amBand = band
            } else {
                station?.fmBand = band
            }
            finishClosure?(error)
        }
    }

    internal override func expanding(model: SectionViewModel?, section: Int, incrementPage: Bool, startClosure: (() -> Void)? = nil, finishClosure: ((_ error: NSError?) -> Void)? = nil) {

        if let isCollapsed = model?.isCollapsed {
            if section == 0 {
                amCatalogViewModel.isCollapsed = !isCollapsed
            } else {
                fmCatalogViewModel.isCollapsed = !isCollapsed
            }
        }

        finishClosure?(nil)
    }

}
