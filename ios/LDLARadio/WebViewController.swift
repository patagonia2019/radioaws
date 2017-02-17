//
//  WebViewController.swift
//  LDLARadio
//
//  Created by javierfuchs on 1/13/17.
//  Copyright © 2017 Apple Inc. All rights reserved.
//

import Foundation
import UIKit
import Localize_Swift
import SCLAlertView
import JFCore

class WebViewController: BaseViewController, UIWebViewDelegate {
    
    var fileName : String?
    var tokens : [String : String]?
    var urlLink : URL?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let web : UIWebView = self.view as? UIWebView else {
            return
        }
        web.scrollView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
        
        if let path = Bundle.main.path(forResource: Localize.currentLanguage(), ofType: "lproj"),
            let bundle = Bundle(path: path),
            let name = fileName
        {
            let url = URL(fileURLWithPath: bundle.bundlePath + "/" + name)
            var content = try! String(contentsOf: url, encoding: String.Encoding.utf8)
            if let tokens = self.tokens {
                for (k,v) in tokens {
                    content = content.replacingOccurrences(of: k, with: v)
                }
                web.loadHTMLString(content, baseURL: bundle.bundleURL)
            }
            else {
                let request = URLRequest(url: url)
                web.loadRequest(request)
            }
        }
        else if let urlLink = urlLink {
            let request = URLRequest(url: urlLink)
            web.loadRequest(request)
        }
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == .linkClicked {
            if let url = request.url {
                UIApplication.shared.openURL(url)
                return false
            }
        }
        return true
    }
    
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
//        SCLAlertView().showError(Global.title.error, subTitle: error.localizedDescription)
        print(error)
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
//        Facade.instance.spinnerStart()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
//        Facade.instance.spinnerStop()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        Analytics.logMemoryWarning(function: #function, line: #line)
    }
    
}
