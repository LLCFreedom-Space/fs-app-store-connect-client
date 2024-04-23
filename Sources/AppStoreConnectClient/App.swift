//
//  App.swift
//  
//
//  Created by Mykola Vasyk on 22.04.2024.
//

import Foundation

public struct App {
    public let id: String
    public let bundleID: String
    
    public init(id: String, bundleID: String) {
        self.id = id
        self.bundleID = bundleID
    }

    init?(schema: Components.Schemas.App) {
        guard let bundleID = schema.attributes?.bundleId else { return nil }
        self.id = schema.id
        self.bundleID = bundleID
    }
}
