// FS App Store Connect Client
// Copyright (C) 2024  FREEDOM SPACE, LLC

//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU Affero General Public License as published
//  by the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU Affero General Public License for more details.
//
//  You should have received a copy of the GNU Affero General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.

//
//  Application.swift
//  
//
//  Created by Mykola Vasyk on 22.04.2024.
//

import Foundation

/// Represents an app in the App Store Connect ecosystem.
public struct Application {
    /// The identifier of the app.
    public let id: String
    /// The bundle identifier of the app.
    public let bundleId: String
    
    /// Initializes an `App` with the provided identifier and bundle identifier.
    /// - Parameters:
    ///   - id: The identifier of the app.
    ///   - bundleId: The bundle identifier of the app.
    public init(id: String, bundleId: String) {
        self.id = id
        self.bundleId = bundleId
    }

    /// Initializes an `App` from an OpenAPI schema representation.
    /// - Parameter schema: The OpenAPI schema representation of the app.
    /// - Returns: An instance of `App` if initialization is successful, otherwise `nil`.
    init?(schema: Components.Schemas.App) {
        guard let bundleId = schema.attributes?.bundleId else {
            return nil
        }
        self.id = schema.id
        self.bundleId = bundleId
    }
}
