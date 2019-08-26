//
//  Searchable.swift
//  LDLARadio
//
//  Created by fox on 27/07/2019.
//  Copyright © 2019 Mobile Patagonia. All rights reserved.
//

import Foundation

internal protocol Searchable: Modellable {

    /// Returns the entities for a given name.
    static func search(byName name: String?) -> [ModelType]?

    /// Fetch an object by url
    static func search(byUrl url: String?) -> ModelType?

    static var placeholderImageName: String { get }

}

/// Placeholder for Thumbnails using Protocol condicional conformance in swift

/// Conditional conformances were introduced in Swift 4.1, and refined in Swift 4.2 to allow you to query them at runtime. They allow types to conform to a protocol only when certain conditions are met – hence “conditional conformance”.
extension Modellable where Self: RNAStation {

    internal static var placeholderImageName: String { get { return "RNA-256x256bb"} }
}

extension Modellable where Self: Stream {

    internal static var placeholderImageName: String { get { return "f0001-music"} }
}

extension Modellable where Self: RTCatalog {

    internal static var placeholderImageName: String { get { return "f0001-music"} }
}

extension Modellable where Self: Bookmark {

    internal static var placeholderImageName: String { get { return "f0001-music"} }
}

extension Modellable where Self: ArchiveCollection {

    internal static var placeholderImageName: String { get { return "f0001-music"} }
}

extension Modellable where Self: ArchiveDoc {

    internal static var placeholderImageName: String { get { return "f0001-music"} }
}

extension Modellable where Self: AudioPlay {

    internal static var placeholderImageName: String { get { return "f0001-music"} }
}
