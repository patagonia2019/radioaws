//
//  WebViewController.swift
//  LDLARadio
//
//  Created by javierfuchs on 1/13/17.
//  Copyright © 2017 Mobile Patagonia. All rights reserved.
//

import Foundation
import UIKit
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
        web.scrollView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        
        let path = Bundle.main.bundlePath
        if let bundle = Bundle(path: path),
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
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        if navigationType == .linkClicked {
            if let url = request.url {
                return false
            }
        }
        return true
    }
    
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        let jferror = JFError(code: Int(errno),
                            desc: "Error",
                            reason: "Player failed",
                            suggestion: "Please check your internet connection",
                            underError: error as NSError?)
        showAlert(error: jferror)
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        Analytics.logMemoryWarning(function: #function, line: #line)
    }
    

}
