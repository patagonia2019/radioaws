//
//  CatalogListViewController.swift
//  LDLARadio
//
//  Created by fox on 11/07/2019.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import UIKit

class CatalogListViewController : UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    var all = [RTCatalog]()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let catalog = sender as? Catalog, let vc = segue.destination as? BrowseViewController {
//            vc.catalog = catalog
//        }
    }
    
}

extension CatalogListViewController {
    private func fetchCatalog() {
    }
}
    
    

