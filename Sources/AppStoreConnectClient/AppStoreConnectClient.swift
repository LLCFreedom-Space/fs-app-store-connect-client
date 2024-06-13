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
                AuthenticationMiddleware(credentials: credentials),
                RetryingMiddleware(),
                RateLimitMiddleware()
            ]
        )
    }
    
    /// Fetches collection of apps from the App Store Connect API,
    /// handles error responses returned by the App Store Connect API when fetching app collections.
    /// End-point: v1/apps
    /// - Returns: An array of `App` objects.
    /// - Throws: An error of type `AppStoreConnectError` if the response indicates an error.
    public func fetchApps() async throws -> [Application] {
        let response = try await client.apps_hyphen_get_collection()
        switch response {
        case .ok(let okResponse):
            return try okResponse.body.json.data.compactMap { Application(schema: $0) }
        case .badRequest(let result):
            throw AppStoreConnectError.badRequest(
                errors: AppStoreConnectError.parseErrorDescription(from: try result.body.json)
            )
        case .forbidden(let result):
            throw AppStoreConnectError.forbidden(
                errors: AppStoreConnectError.parseErrorDescription(from: try result.body.json)
            )
        case .unauthorized(let result):
            throw AppStoreConnectError.unauthorized(
                errors: AppStoreConnectError.parseErrorDescription(from: try result.body.json)
            )
        case .undocumented(let statusCode, _):
            throw AppStoreConnectError.serverError(
                errorCode: statusCode
            )
        }
    }
    
    /// Fetches a collection of versions for a specified app from the App Store Connect API,
    /// handles error responses returned by the App Store Connect API when fetching App Store version by app-id.
    /// End-point: v1/apps/{id}/appStoreVersions
    /// - Parameter app: The app for which to fetch versions.
    /// - Returns: An array of `Release` objects.
    /// - Throws: An error of type `AppStoreConnectError` if the response indicates an error.
    public func fetchVersions(for app: Application) async throws -> [Release] {
        let response = try await client.apps_hyphen_appStoreVersions_hyphen_get_to_many_related(
            path: .init(id: app.id)
        )
        switch response {
        case .ok(let okResponse):
            return try okResponse.body.json.data.compactMap { Release(schema: $0) }
        case .badRequest(let result):
            throw AppStoreConnectError.badRequest(
                errors: AppStoreConnectError.parseErrorDescription(from: try result.body.json)
            )
        case .forbidden(let result):
            throw AppStoreConnectError.forbidden(
                errors: AppStoreConnectError.parseErrorDescription(from: try result.body.json)
            )
        case .notFound(let result):
            throw AppStoreConnectError.notFound(
                errors: AppStoreConnectError.parseErrorDescription(from: try result.body.json)
            )
        case .unauthorized(let result):
            throw AppStoreConnectError.unauthorized(
                errors: AppStoreConnectError.parseErrorDescription(from: try result.body.json)
            )
        case .undocumented(let statusCode, _):
            throw AppStoreConnectError.serverError(errorCode: statusCode)
        }
    }
    
    /// Fetches a collection of TestFlight builds for a specified app from the App Store Connect API,
    /// handles error responses returned by the App Store Connect API when fetching TestFlight builds.
    /// End-point: v1/builds
    /// - Parameters:
    ///   - app: The app for which to fetch builds.
    ///   - sortOptions: The sorting options to be applied to the fetched builds.
    ///   - fieldsOptions: The fields to be included in the fetched builds.
    /// - Returns: An array of `Build` objects.
    /// - Throws: An error of type `AppStoreConnectError` if the response indicates an error.
    public func fetchBuilds(
        for app: Application,
        with query: BuildsQuery
    ) async throws -> [Build] {
        let response = try await client.builds_hyphen_get_collection(
            query: .init(
                filter_lbrack_app_rbrack_: [app.id],
                sort: type(of: query.sort).init(arrayLiteral: ._hyphen_version),
                fields_lbrack_builds_rbrack_: type(of: query.fields).init(
                    arrayLiteral: 
                    .version,
                    .minOsVersion,
                    .uploadedDate
                )
            )
        )
        switch response {
        case .ok(let okResponse):
            return try okResponse.body.json.data.compactMap { Build(schema: $0) }
        case .badRequest(let result):
            throw AppStoreConnectError.badRequest(
                errors: AppStoreConnectError.parseErrorDescription(from: try result.body.json)
            )
        case .unauthorized(let result):
            throw AppStoreConnectError.unauthorized(
                errors: AppStoreConnectError.parseErrorDescription(from: try result.body.json)
            )
        case .forbidden(let result):
            throw AppStoreConnectError.forbidden(
                errors: AppStoreConnectError.parseErrorDescription(from: try result.body.json)
            )
        case .undocumented(let statusCode, _):
            throw AppStoreConnectError.serverError(errorCode: statusCode)
        }
    }
    
    /// Fetches the pre-release version associated with a specific TestFlight's build from the App Store Connect API,
    /// Handles error responses returned by the App Store Connect API when fetching TestFlight's pre-release versions.
    /// End-point: v1/builds/{id}/preReleaseVersion
    /// - Parameter id: The build-id for which to fetch the pre-release version.
    /// - Returns: A `PreReleaseVersion` object.
    /// - Throws: An error of type `AppStoreConnectError` if the response indicates an error.
    public func fetchPreReleaseVersion(for build: Build) async throws -> PreReleaseVersion {
        let id = build.id
        let response = try await client.builds_hyphen_preReleaseVersion_hyphen_get_to_one_related(
            path: .init(id: id)
        )
        switch response {
        case .ok(let okResponse):
            let json = try okResponse.body.json
            return PreReleaseVersion(schema: json)
        case .badRequest(let result):
            throw AppStoreConnectError.badRequest(
                errors: AppStoreConnectError.parseErrorDescription(from: try result.body.json)
            )
        case .unauthorized(let result):
            throw AppStoreConnectError.unauthorized(
                errors: AppStoreConnectError.parseErrorDescription(from: try result.body.json)
            )
        case .forbidden(let result):
            throw AppStoreConnectError.forbidden(
                errors: AppStoreConnectError.parseErrorDescription(from: try result.body.json)
            )
        case .notFound(let result):
            throw AppStoreConnectError.notFound(
                errors: AppStoreConnectError.parseErrorDescription(from: try result.body.json)
            )
        case .undocumented(let statusCode, _):
            throw AppStoreConnectError.serverError(errorCode: statusCode)
        }
    }
}
