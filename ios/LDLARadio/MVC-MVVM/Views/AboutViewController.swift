//
//  AboutViewController.swift
//  LDLARadio
//
//  Created by fox on 26/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import UIKit
import PDFKit
import JFCore

/// A class that is showed in the second tab, it shows my Resumé using PDFKit.
class AboutViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let path = Bundle.main.path(forResource: "javier.fuchs.about", ofType: "pdf") {
            let pdfView = PDFView(frame: view.bounds)
            if let pdfDocument = PDFDocument(url: URL(fileURLWithPath: path)) {
                pdfView.displayMode = .singlePageContinuous
                pdfView.autoScales = true
                pdfView.displayDirection = .vertical
                pdfView.document = pdfDocument
            }
            view.addSubview(pdfView)
            pdfView.widthAnchor.constraint(equalToConstant: view.bounds.size.width).isActive = true
            pdfView.heightAnchor.constraint(equalToConstant: view.bounds.size.height).isActive = true
            pdfView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            pdfView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Analytics.logFunction(function: "about",
                              parameters: ["action": "check" as AnyObject])

    }

    @IBAction func shareAction(_ sender: Any) {
        share(indexPath: nil)
    }

}
