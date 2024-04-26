//
//  Release.swift
//
//
//  Created by Mykola Vasyk on 22.04.2024.
//

import Foundation

/// A struct representing a release of an application.
/// - Parameters:
/// - version: The version string of the release.
/// - appStoreState: The state of the release on the App Store.
/// - Note: This struct provides a convenient way to represent release information, including version and App Store state.
public struct Release {
    /// The version string of the release.
    public let version: String
    /// The state of the release on the App Store.
    public let appStoreState: String
    
    /// Initializes a `Release` instance with the provided App Store version schema.
    /// - Parameters:
    ///    - schema: The schema representing the App Store version.
    ///    - Returns: A new `Release` instance if initialization is successful, nil otherwise.
    ///    - Note: This initializer extracts the version string and App Store state from the provided schema and constructs a `Release` instance.
    ///    - Warning: If the schema does not contain valid version or state information, the initialization will fail.
    init?(schema: Components.Schemas.AppStoreVersion) {
        guard let state = schema.attributes?.appStoreState,
              let version = schema.attributes?.versionString else {
            return nil
        }
        self.appStoreState = state.rawValue
        self.version = version
    }
}
