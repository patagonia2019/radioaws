//
//  Modellable+.swift
//  LDLARadio
//
//  Created by fox on 05/05/2020.
//  Copyright © 2020 Mobile Patagonia. All rights reserved.
//

import Foundation

/// Placeholder for Thumbnails using Protocol condicional conformance in swift

/// Conditional conformances were introduced in Swift 4.1, and refined in Swift 4.2 to allow you to query them at runtime. They allow types to conform to a protocol only when certain conditions are met – hence “conditional conformance”.
extension Modellable where Self: RNAStation {

    internal static var placeholderImageName: String { return "RNA-256x256bb" }
}

extension Modellable where Self: Stream {

    internal static var placeholderImageName: String { return "transistor_radio_logo" }
}

extension Modellable where Self: Desconcierto {

    internal static var placeholderImageName: String { return "logo-quique-pesoa-app-200" }
}

extension Modellable where Self: RTCatalog {

    internal static var placeholderImageName: String { return "radiotime" }
}

extension Modellable where Self: ArchiveCollection {

    internal static var placeholderImageName: String { return "archiveorg" }
}

extension Modellable where Self: ArchiveDoc {

    internal static var placeholderImageName: String { return "archiveorg" }
}

extension Modellable where Self: Audio {

    internal static var placeholderImageName: String { return "f0001-music" }
}
