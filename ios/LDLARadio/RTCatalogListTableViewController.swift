//
//  RTCatalogViewController.swift
//  LDLARadio
//
//  Created by fox on 11/07/2019.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import UIKit
import SwiftSpinner
import JFCore

class RTCatalogViewController : UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

//    private let controller = RTCatalogController()
    
    deinit {
        for note in [RTCatalogManager.didLoadNotification] {
            NotificationCenter.default.removeObserver(self, name: note, object: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        SwiftSpinner.useContainerView(view)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleCatalogManagerDidLoadNotification(_:)), name: RTCatalogManager.didLoadNotification, object: nil)
        
        addRefreshControl()
        
        tableView.remembersLastFocusedIndexPath = true
        
//        if controller.mainCatalog != nil {
//            refresh()
//        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        if mainCatalog == nil {
//            mainCatalog = RTCatalogManager.instance.mainCatalog
//        }
//        if  catalogViewModels.count == 0 {
//            catalogViewModels = RTCatalogManager.instance.catalogs() ?? [CatalogViewModel]()
//        }

        reloadData()
    }
    
    
    /// Refresh control to allow pull to refresh
    private func addRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.accessibilityHint = "refresh"
        refreshControl.accessibilityLabel = "refresh"
        refreshControl.addTarget(self, action:
            #selector(RTCatalogViewController.handleRefresh(_:)),
                                 for: .valueChanged)
        refreshControl.tintColor = UIColor.red
        
        tableView.addSubview(refreshControl)
        
    }

    private func refresh(refreshControl: UIRefreshControl? = nil) {
//        catalogViewModels = [CatalogViewModel]()
        SwiftSpinner.show(Quote.randomQuote())
        reloadData()
        
        RTCatalogManager.instance.clean()
        
//        RTCatalogManager.instance.setup(url: mainCatalog?.url?.absoluteString) { (error) in
//            if error != nil {
//                CoreDataManager.instance.rollback()
//            }
//            else {
//                CoreDataManager.instance.save()
//            }
//            self.catalogViewModels = RTCatalogManager.instance.catalogs() ?? [CatalogViewModel]()
//            if self.mainCatalog == nil {
//                self.mainCatalog = RTCatalogManager.instance.mainCatalog
//            }
//
//            DispatchQueue.main.async {
//                refreshControl?.endRefreshing()
//                SwiftSpinner.hide()
//                self.reloadData()
//            }
//        }
    }
    
    /// Handler of the pull to refresh, it clears the info container, reload the view and made another request using RestApi
    @objc private func handleRefresh(_ refreshControl: UIRefreshControl) {
        refresh(refreshControl: refreshControl)
    }
    
    private func reloadData() {
        tableView.reloadData()
    }
    
    /// MARK: Notification handling
    
    @objc func handleCatalogManagerDidLoadNotification(_: Notification) {
        DispatchQueue.main.async {
            RTCatalogManager.instance.update()
//            self.catalogViewModels = RTCatalogManager.instance.catalogs() ?? [CatalogViewModel]()
            self.reloadData()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == Commons.segue.catalog {
//            (segue.destination as? RTCatalogViewController)?.mainCatalog = sender as? CatalogViewModel
//        }
    }
}


extension RTCatalogViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let model = catalogViewModels[indexPath.row]
//        performSegue(withIdentifier: Commons.segue.catalog, sender: model)
    }
}

//extension RTCatalogViewController : UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return catalogViewModels.count
//    }
//    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return catalogViewModels.first?.title
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if catalogViewModels.count > 0 {
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: CatalogViewModel.hardcode.identifier, for: indexPath) as? CatalogTableViewCell else { fatalError() }
//            cell.model = catalogViewModels[indexPath.row]
//            return cell
//        }
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: CatalogViewModel.hardcode.identifier, for: indexPath) as? CatalogTableViewCell else { fatalError() }
//        return cell
//    }
//}

