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
//  PreReleaseVersion.swift
//
//
//  Created by Mykola Vasyk on 05.06.2024.
//

import Foundation

/// A struct representing a testFlight's pre-release version of an application in the App Store Connect.
/// - Parameters:
///   - id: The unique identifier of the pre-release version.
///   - version: The version string of the pre-release version.
///   - platform: The platform for which the pre-release version is intended.
/// - Note: A pre-release version is a version of an app that is not yet published on the App Store.
public struct PreReleaseVersion {
    /// The unique identifier of the pre-release version.
    public let id: String?
    /// The version string of the pre-release version.
    public let version: String?
    /// The platform for which the pre-release version is intended.
    public let platform: String?
    
    /// Initializes a `PreReleaseVersion` instance with the provided testFlight's pre-release version schema.
    /// - Parameters:
    ///   - schema: The schema representing the pre-release version from the API.
    /// - Note: This initializer extracts the pre-release version metadata from the provided schema and constructs a `PreReleaseVersion` instance.
    /// - Warning: If the schema does not contain valid metadata, some properties of the `PreReleaseVersion` instance may be nil.
    init(schema: Components.Schemas.PrereleaseVersionWithoutIncludesResponse) {
        self.id = schema.data.id
        self.version = schema.data.attributes?.version
        self.platform = schema.data.attributes?.platform?.rawValue
    }
}

/// Enumerates possible errors that can occur when working with `PreReleaseVersion`.
public enum PreReleaseVersionError: Error {
    /// Indicates that the ID of a build is `nil` when it's expected to have a value.
    case idIsNil
}
