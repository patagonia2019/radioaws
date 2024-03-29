//
//  RadioController.swift
//  LDLARadio
//
//  Created by fox on 22/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import JFCore

class RadioController: BaseController {

    var catalogViewModel = SectionViewModel()
    private var models = [AudioViewModel]()

    override init() {
        catalogViewModel.title.text = "Los Locos de la Azotea"
        catalogViewModel.audios = models
    }

    init(withStreams streams: [Stream]?) {
        super.init()
        models = streams?.map({ AudioViewModel(stream: $0) }).filter({ (model) -> Bool in
            model.url?.absoluteString.isEmpty == false
        }) ?? [AudioViewModel]()
    }

    override func numberOfRows(inSection section: Int) -> Int {
        let rows: Int = models.count
        return rows > 0 ? rows : 1
    }

    override func model(forSection section: Int, row: Int) -> Any? {
        if row < models.count {
            return models[row]
        }
        return nil
    }

    override func modelInstance(inSection section: Int) -> SectionViewModel? {
        return catalogViewModel
    }

    private func updateModels() {
        if let streams = Stream.all()?.filter({ (stream) -> Bool in
            stream.url?.isEmpty == false
        }) {
            models = streams.map({ AudioViewModel(stream: $0) }).filter({ (model) -> Bool in
                model.url?.absoluteString.isEmpty == false
            })
        }
        lastUpdated = Stream.lastUpdated()
    }

    override func privateRefresh(isClean: Bool = false,
                                 prompt: String,
                                 finishClosure: ((_ error: JFError?) -> Void)? = nil) {

        var resetInfo = false
        if isClean {
            resetInfo = true
        }

        if resetInfo == false {
            updateModels()
            if !models.isEmpty {
                finishClosure?(nil)
                return
            }
        }

        RestApi.instance.context?.performAndWait {

            StreamListManager.instance.clean()
            StationListManager.instance.clean()
            CityListManager.instance.clean()

            StreamListManager.instance.setup { (error) in
                if error != nil {
                    CoreDataManager.instance.rollback()
                } else {
                    CoreDataManager.instance.save()
                }
                self.updateModels()

                DispatchQueue.main.async {
                    finishClosure?(error)
                }
            }
        }
    }

    private func expanding(model: SectionViewModel?, section: Int, incrementPage: Bool, finishClosure: ((_ error: JFError?) -> Void)? = nil) {

        if let isCollapsed = model?.isCollapsed {
            catalogViewModel.isCollapsed = !isCollapsed
        }

        finishClosure?(nil)
    }

}
