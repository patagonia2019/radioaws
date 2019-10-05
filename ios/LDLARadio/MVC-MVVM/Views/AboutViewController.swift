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
            if #available(iOS 11.0, *) {
                let pdfView = PDFView(frame: view.bounds)
                if let pdfDocument = PDFDocument(url: URL(fileURLWithPath: path)) {
                    pdfView.displayMode = .singlePageContinuous
                    pdfView.autoScales = true
                    pdfView.displayDirection = .vertical
                    pdfView.document = pdfDocument
                }
                pdfView.widthAnchor.constraint(equalToConstant: view.bounds.size.width)
                pdfView.heightAnchor.constraint(equalToConstant: view.bounds.size.height)
                pdfView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
                pdfView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
                view.addSubview(pdfView)
            } else {
                let req = URLRequest(url: URL.init(fileURLWithPath: path))
                let webView = UIWebView(frame: view.bounds)
                webView.loadRequest(req)
                view.addSubview(webView)
            }
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
