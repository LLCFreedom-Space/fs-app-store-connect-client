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
//  AppStoreConnectClientProtocol.swift
//
//
//  Created by Mykola Vasyk on 24.05.2024.
//

import Foundation

/// A protocol defining the interface for searching the App Store Connect.
public protocol AppStoreConnectClientProtocol {
    /// Fetches a list of applications from App Store Connect.
    /// - Throws:
    ///   - AppStoreConnectClientError: An error that may occur during the fetch process.
    /// - Returns: An array of `Application` objects representing the retrieved applications.
    func fetchApps() async throws -> [Application]
    
    /// Fetches a list of versions for a specific application from App Store Connect.
    /// - Parameters:
    ///   - app: The `Application` object representing the app whose versions are to be fetched.
    /// - Throws:
    ///   - AppStoreConnectClientError: An error that may occur during the fetch process.
    /// - Returns: An array of `Release` objects containing details about the retrieved versions.
    func fetchVersions(for app: Application) async throws -> [Release]
}
