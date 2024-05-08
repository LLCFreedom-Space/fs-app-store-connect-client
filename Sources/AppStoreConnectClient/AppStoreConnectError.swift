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
//  AppStoreConnectError.swift
//
//
//  Created by Mykola Vasyk on 19.04.2024.
//

import Foundation

/// An enumeration of errors that may occur during interactions with the App Store Connect API.
public enum AppStoreConnectError: Error, Equatable {
    /// A server-side error occurred, indicated by the provided status code.
    case serverError(errorCode: Int)
    /// No results were found for the specified bundle ID.
    case unauthorized(errors: String?)
    /// The request is forbidden.
    case forbidden(errors: String?)
    /// The request is malformed or contains invalid parameters.
    case badRequest(errors: String?)
    /// The requested resource was not found.
    case notFound(errors: String?)
    
    case unexpectedError(errors: String?)
}
