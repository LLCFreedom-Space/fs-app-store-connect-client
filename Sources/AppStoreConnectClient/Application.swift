//
//  Application.swift
//  
//
//  Created by Mykola Vasyk on 22.04.2024.
//

import Foundation
import SwiftUI

/// Represents an app in the App Store Connect ecosystem.
public struct Application {
    /// The identifier of the app.
    public let id: String
    /// The bundle identifier of the app.
    public let bundleID: String
    
    /// Initializes an `App` with the provided identifier and bundle identifier.
    /// - Parameters:
    ///   - id: The identifier of the app.
    ///   - bundleID: The bundle identifier of the app.
    public init(id: String, bundleID: String) {
        self.id = id
        self.bundleID = bundleID
    }

    /// Initializes an `App` from an OpenAPI schema representation.
    /// - Parameter schema: The OpenAPI schema representation of the app.
    /// - Returns: An instance of `App` if initialization is successful, otherwise `nil`.
    init?(schema: Components.Schemas.App) {
        guard let bundleID = schema.attributes?.bundleId else {
            return nil
        }
        self.id = schema.id
        self.bundleID = bundleID
    }
}
