//
//  RestApi.swift
//  LDLARadio
//
//  Created by fox on 10/07/2019.
//  Copyright © 2019 Apple Inc. All rights reserved.
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
        
    /// Some hardcoded constants
    struct Constants {
        struct Service {
            
            /// The timeout used in the test expectations and requests in RestApi.
            static let timeout: TimeInterval = 4
            
            /// The current server where all the requests were made.
            static let server: String = UserDefaults.standard.string(forKey: "server_url") ?? "http://adminradio.serveftp.com:35111"
            
            /// Function to build the base url used in the requests.
            static func baseUrl() -> String {
                return "\(Constants.Service.server)"
            }
            
            /// Function to build the url used in the requests.
            static func url(with query: String?) -> String {
                return "\(baseUrl())\(query ?? "")"
            }
        }
        
    }
    
    /// Instance of alamofire configured with a timeout.
    private let alamofire = { () -> Alamofire.SessionManager in
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = Constants.Service.timeout
        return manager
    }()
    
    
    /// Request with Insert in Core Data
    /// T: Insertable: protocol that is used to insert any converted JSON object into Core Data model object.
    /// query: uri to build the url
    /// type: The class that implement insertable protocol
    /// finish: closure to know if there is an error in the request/json conversion/core data insert
    func request<T: Insertable>(
        usingQuery query: String,
        method: HTTPMethod = .get,
        type: T.Type,
        finish: ((_ error: Error?) -> Void)? = nil)
    {
        guard let context = CoreDataManager.instance.taskContext else { fatalError() }

        let url = Constants.Service.url(with: query)
        
        let request = alamofire.request(url, method: method, parameters: nil, encoding: JSONEncoding.default).validate()
        request.responseInsert(context: context, type: T.self) { response in
            print("\n\(request.debugDescription.replacingOccurrences(of: "\\\n\t", with: " "))\nRESPONSE:\n\(response.dataAsString())\n")
            finish?(response.error)
        }
    }

}

extension DataResponse {
    func dataAsString() -> String {
        if let data = data,
            let str = String.init(data: data, encoding: .ascii) {
            return str
        }
        return ""
    }
}
