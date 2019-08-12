//
//  ArchiveDoc+.swift
//  LDLARadio
//
//  Created by fox on 12/08/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation

extension ArchiveDoc {
    
    func subjectString() -> String? {
        if let subject = subject as? String {
            return subject
        }
        else if let subject = subject as? [String] {
            return subject.joined(separator: ", ")
        }
        return nil
    }
    
    func urlString() -> String? {
        if let identifier = identifier {
            return "\(RestApi.Constants.Service.archServer)/details/\(identifier)"
        }
        return nil
    }

}
