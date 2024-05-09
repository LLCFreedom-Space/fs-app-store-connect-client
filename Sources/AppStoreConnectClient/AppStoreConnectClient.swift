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
//  AppStoreConnectClient.swift
//
//
//  Created by Mykola Vasyk on 22.04.2024.
//

import OpenAPIURLSession
import Foundation

/// The client for interacting with the App Store Connect API.
public struct AppStoreConnectClient {
    private let client: any APIProtocol
    
    /// Initializes the client with a custom API protocol implementation.
    /// - Parameter client: An instance conforming to `AnyAPIProtocol`.
    init(client: any APIProtocol) {
        self.client = client
    }
    
    /// Initializes the client with App Store Connect credentials.
    /// - Parameter credentials: Credentials needed to authenticate with the App Store Connect API.
    /// - Throws: An error if initialization fails.
    public init(with credentials: Credentials) throws {
        self.client = try Client(
            serverURL: Servers.server1(),
            transport: URLSessionTransport(),
            middlewares: [
                AuthenticationMiddleware(credentials: credentials)
            ]
        )
    }
    
    /// Fetches collection of apps from the App Store Connect API.
    /// - Returns: An array of `App` objects.
    /// - Throws: An error if the fetch operation fails.
    public func fetchApps() async throws -> [Application] {
        let response = try await client.apps_hyphen_get_collection()
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let json):
                return json.data.compactMap({ Application(schema: $0) })
            }
        case .badRequest:
                throw AppStoreConnectError.badRequest(errors: errorDescription(from: response))
        case .forbidden(let result):
                throw AppStoreConnectError.forbidden(errors: errorDescription(from: response))
        case .unauthorized(let result):
                throw AppStoreConnectError.unauthorized(errors: errorDescription(from: response))
        case .undocumented(let statusCode, _):
            throw AppStoreConnectError.serverError(errorCode: statusCode)
        }
    }
    
    /// Converts an error response into a formatted string.
    /// - Parameter response: The error response object.
    /// - Returns: A formatted string describing the error response, or `nil` if the response is empty.
    private func errorDescription(
        from response: Operations.apps_hyphen_get_collection.Output
    ) -> String? {
        var stringError = ""
        switch response {
        case .badRequest(let result):
            switch result.body {
            case .json(let json):
                do {
                    try response.badRequest.body.json.errors?.forEach { error in
                        stringError.append("""
                        \nThe request failed with: \(error.status), \(error.code), \(error.title), \(error.detail).
                        """)
                    }
                } catch {
                    return nil
                }
            }
        case .forbidden(let result):
            switch result.body {
            case .json(let json):
                do {
                    try response.forbidden.body.json.errors?.forEach { error in
                        stringError.append("""
                        \nThe request failed with: \(error.status), \(error.code), \(error.title), \(error.detail).
                        """)
                    }
                } catch {
                    return nil
                }
            }
        case .unauthorized(let result):
            switch result.body {
            case .json(let json):
                do {
                    try response.unauthorized.body.json.errors?.forEach { error in
                        stringError.append("""
                        \nThe request failed with: \(error.status), \(error.code), \(error.title), \(error.detail).
                        """)
                    }
                } catch {
                    return nil
                }
            }
        default:
            break
        }
        guard !stringError.isEmpty else {
            return nil
        }
        return stringError
    }
    
    /// Fetches a collection of versions for a specified app from the App Store Connect API.
    /// - Parameter app: The app for which to fetch versions.
    /// - Returns: An array of `Release` objects.
    /// - Throws: An error of type `AppStoreConnectError` if the fetch operation fails.
    public func fetchVersions(for app: Application) async throws -> [Release] {
        let response = try await client.apps_hyphen_appStoreVersions_hyphen_get_to_many_related(
            path: .init(id: app.id)
        )
        switch response {
        case .ok(let okResponse):
            if case .json(let json) = okResponse.body {
                return json.data.compactMap({ Release(schema: $0) })
            }
        default:
            return try errorResponse(from: response)
        }
        throw AppStoreConnectError.unexpectedError(errors: "\(response)")
    }
    
    /// Handles error responses returned by the App Store Connect API.
    /// - Parameter response: The response received from the API.
    /// - Throws: An error of type `AppStoreConnectError` if the response indicates an error.
    private func errorResponse(
        from response: Operations.apps_hyphen_appStoreVersions_hyphen_get_to_many_related.Output
    ) throws -> [Release] {
        switch response {
        case .badRequest(let result):
            switch result.body {
            case .json(let json):
                throw AppStoreConnectError.badRequest(errors: errorDescription(from: json))
            }
        case .forbidden(let result):
            switch result.body {
            case .json(let json):
                throw AppStoreConnectError.forbidden(errors: errorDescription(from: json))
            }
        case .notFound(let result):
            switch result.body {
            case .json(let json):
                throw AppStoreConnectError.notFound(errors: errorDescription(from: json))
            }
        case .unauthorized(let result):
            switch result.body {
            case .json(let json):
                throw AppStoreConnectError.unauthorized(errors: errorDescription(from: json))
            }
        case .undocumented(let statusCode, _):
            throw AppStoreConnectError.serverError(errorCode: statusCode)
            
        default:
            throw AppStoreConnectError.unexpectedError(errors: "\(response)")
        }
    }
}
