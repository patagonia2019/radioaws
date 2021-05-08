//
//  SearchController.swift
//  LDLARadio
//
//  Created by fox on 03/08/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation

class SearchController: BaseController {

    /// Notification for when bookmark has changed.
    static let didRefreshNotification = NSNotification.Name(rawValue: "SearchController.didRefreshNotification")

    private var models = [SectionViewModel]()
    private var page: Int = 1

    private var textList = [String]()
    private var isAlreadyDone: Bool = false
    var textToSearch = String()

    override var useRefresh: Bool {
        return true
    }

    override init() {
    }

    init(withText text: String?) {
        if let text = text, !text.isEmpty {
            textToSearch = text
        }
    }

    override func title() -> String {
        return "Search: \(textToSearch)"
    }

    override func numberOfSections() -> Int {
        return models.count
    }

    override func numberOfRows(inSection section: Int) -> Int {
        var rows: Int = 0
        if section < models.count {
            let model = models[section]
            if model.isCollapsed == true {
                return 0
            }
            if model.section == AudioViewModel.ControllerName.ArchiveOrg.rawValue {
                return model.sections.count + 1
            }
            rows = model.sections.count + model.audios.count
        }
        return rows > 0 ? rows : 1
    }

    override func modelInstance(inSection section: Int) -> SectionViewModel? {
        if section < models.count {
            let model = models[section]
            return model
        }
        return models.first
    }

    override func model(forSection section: Int, row: Int) -> Any? {
        if section < models.count {
            let model = models[section]
            if row < (model.sections.count + model.audios.count) {
                if row < model.sections.count {
                    return model.sections[row]
                }
                let audioRow = row - model.sections.count
                if audioRow < model.audios.count {
                    return model.audios[audioRow]
                }
            } else {
                if row < model.audios.count {
                    return model.audios[row]
                }
            }
        }
        return nil
    }

    override func privateRefresh(isClean: Bool = false,
                                 prompt: String,
                                 finishClosure: ((_ error: NSError?) -> Void)? = nil) {

        if isClean == false {
            isAlreadyDone = textList.contains(textToSearch)
        } else {
            isAlreadyDone = false
        }

        if textToSearch.isEmpty {
            finishClosure?(nil)
            return
        }

        models = [SectionViewModel]()

        RestApi.instance.context?.performAndWait {
            if let rnaStations = RNAStation.search(byName: textToSearch), !rnaStations.isEmpty {
                let amModels = rnaStations.filter({ (station) -> Bool in
                    station.amUri?.isEmpty == false
                }).map({ AudioViewModel(station: $0, isAm: true) })
                if !amModels.isEmpty {
                    let model = SectionViewModel()
                    model.isCollapsed = true
                    model.audios = amModels
                    model.section = AudioViewModel.ControllerName.RNA.rawValue
                    model.title.text = "\(model.section) - AM:  \(model.audios.count)"
                    models.append(model)
                }

                let fmModels = rnaStations.filter({ (station) -> Bool in
                    guard let fmUri = station.fmUri else { return false }
                    return !fmUri.isEmpty
                }).map({ AudioViewModel(station: $0, isAm: false) })

                if !fmModels.isEmpty {
                    let model = SectionViewModel()
                    model.isCollapsed = true
                    model.audios = fmModels
                    model.section = AudioViewModel.ControllerName.RNA.rawValue
                    model.title.text = "\(model.section) - FM:  \(model.audios.count)"
                    models.append(model)
                }
            }

            if let streams = Stream.search(byName: textToSearch), !streams.isEmpty {
                let streamModels = streams.map({ AudioViewModel(stream: $0) })
                if !streamModels.isEmpty {
                    let model = SectionViewModel()
                    model.isCollapsed = true
                    model.section = AudioViewModel.ControllerName.LosLocos.rawValue
                    model.audios = streamModels
                    model.title.text = "\(model.section): \(model.audios.count)"
                    models.append(model)
                }
            }

            if let audios = Audio.search(byName: self.textToSearch), !audios.isEmpty {
                let audioModels = audios.map({ AudioViewModel(audio: $0) })
                if !audioModels.isEmpty {
                    let model = SectionViewModel()
                    model.isCollapsed = true
                    model.audios = audioModels
                    model.section = AudioViewModel.ControllerName.MyPick.rawValue
                    model.title.text = "\(model.section):  \(model.audios.count)"
                    self.models.append(model)
                }
            }

        }

        let closure = {
            if let catalogs = RTCatalog.search(byName: self.textToSearch), !catalogs.isEmpty {
                var audiosTmp = [AudioViewModel]()

                let model = SectionViewModel()
                model.isCollapsed = true

                for element in catalogs {
                    if element.isAudio() {
                        let viewModel = AudioViewModel(catalog: element)
                        if audiosTmp.first(where: { (avm) -> Bool in
                            avm.url == viewModel.url
                        }) == nil {
                            audiosTmp.append(viewModel)
                        }
                    } else {
                        model.sections.append(SectionViewModel(catalog: element))
                    }
                }
                if !audiosTmp.isEmpty {
                    model.audios = audiosTmp
                }
                if !model.sections.isEmpty && !model.audios.isEmpty {
                    self.models.append(model)
                }
                model.section = AudioViewModel.ControllerName.RT.rawValue
                model.title.text = "\(model.section):  \(model.sections.count)"
            }

            if let archiveOrgs = ArchiveDoc.search(byName: self.textToSearch), !archiveOrgs.isEmpty {
                let model = SectionViewModel()
                model.isCollapsed = false
                model.sections = archiveOrgs.map({ SectionViewModel(archiveDoc: $0) })
                model.section = AudioViewModel.ControllerName.ArchiveOrg.rawValue
                model.title.text = "\(model.section):  \(model.sections.count)"

                if !model.sections.isEmpty {
                    if self.page == 1 {
                        self.page = model.sections.count / 10 + 1
                    }
                    self.models.append(model)
                }
            }

            self.lastUpdated = Date()

            finishClosure?(nil)
        }

        if isClean && isAlreadyDone == false {

            Analytics.logFunction(function: "search",
                                  parameters: ["text": textToSearch as AnyObject])

            RadioTimeController.search(text: textToSearch, finishClosure: { (_) in

                ArchiveOrgController.search(text: self.textToSearch,
                                            pageNumber: self.page,
                                            finishClosure: { (_) in
                    RestApi.instance.context?.performAndWait {

                        self.textList.append(self.textToSearch)

                        closure()
                    }
                })
            })

        } else {
            closure()
        }
    }

    internal override func expanding(model: SectionViewModel?, section: Int, incrementPage: Bool, startClosure: (() -> Void)? = nil, finishClosure: ((_ error: NSError?) -> Void)? = nil) {
        if incrementPage {
            page += 1
            refresh(isClean: true, prompt: "", startClosure: startClosure, finishClosure: finishClosure)
        } else {
            if let isCollapsed = model?.isCollapsed {
                model?.isCollapsed = !isCollapsed
            }

            finishClosure?(nil)
        }
    }

}
