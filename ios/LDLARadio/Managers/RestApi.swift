//
//  RestApi.swift
//  LDLARadio
//
//  Created by fox on 10/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireCoreData
import CoreData
import Groot
import JFCore


/// A singleton that manages all the configuration, request to the server using Alamofire, automatic json conversion with Groot into Core Data instances (AlamofireCoreData)
class RestApi {
    
    /// Singleton
    static let instance = RestApi()
    
    var context : NSManagedObjectContext? = nil

    /// Some hardcoded constants
    struct Constants {
        struct Service {
            
            /// The timeout used in the test expectations and requests in RestApi.
            static let timeout: TimeInterval = 10
            
            /// The current server where all the requests were made.
            static let ldlaServer: String = UserDefaults.standard.string(forKey: "server_url") ?? "http://adminradio.serveftp.com:35111"
            
            /// RT Server
            static let rtServer: String = "https://api.radiotime.com"

            /// RNA Server
            static let rnaServer: String = "http://marcos.mineolo.com/rna"
            
            /// Archive Server
            static let archServer: String = "https://archive.org"
            
            /// Function to build the url used in the requests.
            static func url(with query: String?, baseUrl: String = ldlaServer) -> String {
                return "\(baseUrl)\(query ?? "")"
            }
        }
        
    }
    
    /// Instance of alamofire configured with a timeout.
    private let alamofire = { () -> Alamofire.SessionManager in
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = Constants.Service.timeout
        return manager
    }()
    
    
    /// Request in RNA server with Insert in Core Data
    /// T: Insertable: protocol that is used to insert any converted JSON object into Core Data model object.
    /// query: uri to build the url
    /// type: The class that implement insertable protocol
    /// finish: closure to know if there is an error in the request/json conversion/core data insert
    func requestRNA<T: Insertable>(
        usingQuery query: String,
        type: T.Type,
        finish: ((_ error: JFError?, _ value: T?) -> Void)? = nil)
    {
        let url = Constants.Service.url(with: query, baseUrl: Constants.Service.rnaServer)
        request(usingUrl: url, method: .get, type: type, finish: finish)
    }
    
    /// Request in LDLA server with Insert in Core Data
    /// T: Insertable: protocol that is used to insert any converted JSON object into Core Data model object.
    /// query: uri to build the url
    /// type: The class that implement insertable protocol
    /// finish: closure to know if there is an error in the request/json conversion/core data insert
    func requestLDLA<T: Insertable>(
        usingQuery query: String,
        type: T.Type,
        finish: ((_ error: JFError?, _ value: T?) -> Void)? = nil)
    {
        let url = Constants.Service.url(with: query, baseUrl: Constants.Service.ldlaServer)
        request(usingUrl: url, method: .get, type: type, finish: finish)
    }
    
    /// Request in RT server with Insert in Core Data using RTServer
    /// T: Insertable: protocol that is used to insert any converted JSON object into Core Data model object.
    /// query: uri to build the url
    /// type: The class that implement insertable protocol
    /// finish: closure to know if there is an error in the request/json conversion/core data insert
    func requestRT<T: Insertable>(
        usingQuery query: String? = "",
        type: T.Type,
        finish: ((_ error: JFError?, _ value: T?) -> Void)? = nil)
    {
        let url = Constants.Service.url(with: query, baseUrl: Constants.Service.rtServer)
        requestRT(usingUrl: url, type: type, finish: finish)
    }
    
    /// Request in RT server with Insert in Core Data using RTServer
    /// T: Insertable: protocol that is used to insert any converted JSON object into Core Data model object.
    /// url: the url
    /// type: The class that implement insertable protocol
    /// finish: closure to know if there is an error in the request/json conversion/core data insert
    func requestRT<T: Insertable>(
        usingUrl url: String?,
        type: T.Type,
        finish: ((_ error: JFError?, _ value: T?) -> Void)? = nil)
    {
        var urlJson : String = url ?? Constants.Service.rtServer
        if urlJson.contains("?") {
            urlJson += "&"
        }
        else {
            urlJson += "?"
        }
        urlJson += "render=json"
        request(usingUrl: urlJson, method: .get, type: type, finish: finish)
    }
    
    /// Request in Archive server with Insert in Core Data using RTServer
    /// T: Insertable: protocol that is used to insert any converted JSON object into Core Data model object.
    /// url: the url
    /// type: The class that implement insertable protocol
    /// finish: closure to know if there is an error in the request/json conversion/core data insert
    func requestARCH<T: Insertable>(
        usingUrl url: String?,
        type: T.Type,
        finish: ((_ error: JFError?, _ value: T?) -> Void)? = nil)
    {
        var urlJson : String = url ?? Constants.Service.archServer
        
        if urlJson.contains("?") {
            urlJson += "&"
        }
        else {
            urlJson += "?"
        }
        urlJson += "output=json"
        request(usingUrl: urlJson, method: .get, type: type, finish: finish)
    }

    /// Request with Insert in Core Data
    /// T: Insertable: protocol that is used to insert any converted JSON object into Core Data model object.
    /// url: url
    /// type: The class that implement insertable protocol
    /// finish: closure to know if there is an error in the request/json conversion/core data insert
    
    func request<T: Insertable>(
        usingUrl url: String,
        method: HTTPMethod = .get,
        type: T.Type,
        finish: ((_ error: JFError?, _ value: T?) -> Void)? = nil)
    {
        guard let context = context ?? CoreDataManager.instance.taskContext else { fatalError() }
        let request = alamofire.request(url, method: method, parameters: nil, encoding: JSONEncoding.default).validate()
        print("\n\(request.debugDescription.replacingOccurrences(of: "\\\n\t", with: " "))\n")
        Analytics.logFunction(function: "request", parameters: ["url": url as AnyObject])
        request.responseInsert(context: context, type: T.self) { response in
            context.performAndWait({
                print("\n\(request.debugDescription.replacingOccurrences(of: "\\\n\t", with: " "))\nRESPONSE:\n\(response.dataAsString())\n")
                var error : JFError? = nil
                if response.error != nil {
                    var desc = "Error"
                    var suggestion = "Please try again later"
                    var reason = response.dataAsString()
                    if reason.count == 0 {
                        desc = "The server is not responding the request"
                        suggestion = "Please check your internet connection"
                        reason = "Empty response"
                    }
                    error = JFError(code: Int(errno),
                                     desc: desc,
                                     reason: reason,
                                     suggestion: suggestion,
                        underError: response.error as NSError?)
                }
                finish?(error, response.value)
            })
        }
    }
    
    func download(usingUrl url: String,
                  localFilePath: String,
                  progressFraction: ((_ fraction: Int) -> Void)? = nil,
                  finish: ((_ error: JFError?, _ filePath: String?) -> Void)? = nil)
    {
        let fm = FileManager.default
        if fm.fileExists(atPath: localFilePath),
            let fileSize = try? fm.attributesOfItem(atPath: localFilePath)[.size] as? NSNumber,
            Double(truncating: fileSize) > 0 {
            finish?(nil, localFilePath)
            return
        }
        
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        alamofire.download(
            url,
            method: .get,
            encoding: PropertyListEncoding.default,
            headers: nil,
            to: destination)
            .downloadProgress(closure: { (progressDownload) in
                let value = Int(progressDownload.fractionCompleted * 100)
                progressFraction?(value)
            }).response(completionHandler: { (downloadResponse) in
                finish?(nil, localFilePath)
            })
    }
}

extension DataResponse {
    func dataAsString() -> String {
        if let data = data,
            let str = String.init(data: data, encoding: .ascii)?.html2String() {
            return str
        }
        return ""
    }
}
