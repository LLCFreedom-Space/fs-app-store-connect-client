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
//  Build.swift
//
//
//  Created by Mykola Vasyk on 29.05.2024.
//

import Foundation

/// A struct representing a testFlight's builds of an application in the App Store Connect.
/// - Parameters:
///   - id: The unique identifier of the build.
///   - version: The version string of the build.
///   - uploadedDate: The date and time when the build was uploaded.
///   - minOsVersion: The minimum required OS version for the build.
/// - Note: A build is a specific version of an app that has been uploaded to App Store Connect.
/// It contains metadata such as the build version, upload date, and minimum supported OS version.
public struct Build: Equatable {
    /// The unique identifier of the build.
    public let id: String
    /// The version string of the build.
    public let version: String?
    /// The date and time when this build was uploaded to App Store Connect.
    public let uploadedDate: Date?
    /// The minimum version of the operating system required to run this build.
    public let minOsVersion: String?
    
    /// Initializes a `Build` instance with the provided App Store Connect build schema.
    /// - Parameters:
    ///   - schema: The schema representing the build from the API.
    /// - Returns: A new `Build` instance if initialization is successful, nil otherwise.
    /// - Note: This initializer extracts the build metadata from the provided schema and constructs a `Build` instance.
    /// - Warning: If the schema does not contain valid metadata, some properties of the `Build` instance may be nil.
    init(schema: Components.Schemas.Build) {
        self.id = schema.id
        self.version = schema.attributes?.version
        self.uploadedDate = schema.attributes?.uploadedDate
        self.minOsVersion = schema.attributes?.minOsVersion
    }
}
