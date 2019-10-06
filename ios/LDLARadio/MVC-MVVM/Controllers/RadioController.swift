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

    var catalogViewModel = CatalogViewModel()
    private var models = [AudioViewModel]()

    override init() {
        catalogViewModel.title.text = "Los Locos de la Azotea"
        catalogViewModel.audios = models
    }

    init(withStreams streams: [Stream]?) {
        super.init()
        models = streams?.map({ AudioViewModel(stream: $0) }).filter({ (model) -> Bool in
            model.url?.absoluteString.count ?? 0 > 0
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

    override func modelInstance(inSection section: Int) -> CatalogViewModel? {
        return catalogViewModel
    }

    override func heightForHeader(at section: Int) -> CGFloat {
        return 0
    }

    override func heightForRow(at section: Int, row: Int) -> CGFloat {
        if let model = model(forSection: section, row: row) as? AudioViewModel {
            return CGFloat(model.height())
        }
        return 0
    }

    private func updateModels() {
        if let streams = Stream.all()?.filter({ (stream) -> Bool in
            stream.url?.count ?? 0 > 0
        }) {
            models = streams.map({ AudioViewModel(stream: $0) }).filter({ (model) -> Bool in
                model.url?.absoluteString.count ?? 0 > 0
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

    private func expanding(model: CatalogViewModel?, section: Int, incrementPage: Bool, finishClosure: ((_ error: JFError?) -> Void)? = nil) {

        if let isExpanded = model?.isExpanded {
            catalogViewModel.isExpanded = !isExpanded
        }

        finishClosure?(nil)
    }

}
