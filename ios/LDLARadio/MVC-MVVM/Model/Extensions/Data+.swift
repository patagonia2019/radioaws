//
//  Data+.swift
//  LDLARadio
//
//  Created by fox on 25/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation

extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
    
    
    func mimeType() -> String {
        
        var b: UInt8 = 0
        copyBytes(to: &b, count: 1)
        
        switch b {
        case 0x3C:
            return "audio/mpeg"
        case 0xFF:
            return "image/jpeg"
        case 0x89:
            return "image/png"
        case 0x47:
            return "image/gif"
        case 0x4D, 0x49:
            return "image/tiff"
        case 0x25:
            return "application/pdf"
        case 0xD0:
            return "application/vnd"
        case 0x46:
            return "text/plain"
        default:
            return "application/octet-stream"
        }
    }

}

