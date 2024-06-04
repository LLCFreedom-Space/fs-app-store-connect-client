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
    
    /// Fetches collection of apps from the App Store Connect API.
    /// - Returns: An array of `App` objects.
    /// - Throws: An error if the fetch operation fails.
    public func fetchApps() async throws -> [Application] {
        let response = try await client.apps_hyphen_get_collection()
        let result: [Application]
        switch response {
        case .ok(let okResponse):
            result = try okResponse.body.json.data.compactMap({ Application(schema: $0) })
        default:
            let error = try handleErrors(from: response)
            throw error
        }
        return result
    }
    
    /// Fetches a collection of versions for a specified app from the App Store Connect API.
    /// - Parameter app: The app for which to fetch versions.
    /// - Returns: An array of `Release` objects.
    /// - Throws: An error of type `AppStoreConnectError` if the fetch operation fails.
    public func fetchVersions(for app: Application) async throws -> [Release] {
        let response = try await client.apps_hyphen_appStoreVersions_hyphen_get_to_many_related(
            path: .init(id: app.id)
        )
        let result: [Release]
        switch response {
        case .ok(let okResponse):
            result = try okResponse.body.json.data.compactMap({ Release(schema: $0) })
        default:
            let error = try handleErrors(from: response)
            throw error
        }
        return result
    }
    
    func fetchBuildVersions() async throws -> [Components.Schemas.Build] {
        let response = try await client.builds_hyphen_get_collection(
            query: .init(
                fields_lbrack_builds_rbrack_: .init(arrayLiteral: .version),
                fields_lbrack_diagnosticSignatures_rbrack_: .init(arrayLiteral: .diagnosticType),
                fields_lbrack_buildBetaDetails_rbrack_: .init(arrayLiteral: .externalBuildState),
                fields_lbrack_betaAppReviewSubmissions_rbrack_: .init(arrayLiteral: .betaReviewState),
                fields_lbrack_appStoreVersions_rbrack_: .init(arrayLiteral: .versionString),
                fields_lbrack_betaBuildLocalizations_rbrack_: .init(arrayLiteral: .build),
                fields_lbrack_preReleaseVersions_rbrack_: .init(arrayLiteral: .version),
                fields_lbrack_appEncryptionDeclarations_rbrack_: .init(arrayLiteral: .app),
                fields_lbrack_apps_rbrack_: .init(arrayLiteral: .bundleId),
                fields_lbrack_perfPowerMetrics_rbrack_: .init(arrayLiteral: .platform)
            )
        )
        print("\n<<< response = \(response)")
        let result: [Components.Schemas.Build]
        var responseJson: Components.Schemas.BuildsResponse
        switch response {
        case .ok(let okResponse):
            responseJson = try okResponse.body.json
        default:
            let error = try handleErrors(from: response)
            throw error
        }
        result = responseJson.data
        return result
    }
    
    /// Handles error responses returned by the App Store Connect API when fetching app collections.
    /// - Parameter response: The response received from the API.
    /// - Throws: An error of type `AppStoreConnectError` if the response indicates an error.
    private func handleErrors(
        from response: Operations.apps_hyphen_get_collection.Output
    ) throws -> AppStoreConnectError {
        switch response {
        case .badRequest(let result):
            return AppStoreConnectError.badRequest(
                errors: AppStoreConnectError.parseErrorDescription(from: try result.body.json)
            )
        case .forbidden(let result):
            return AppStoreConnectError.forbidden(
                errors: AppStoreConnectError.parseErrorDescription(from: try result.body.json)
            )
        case .unauthorized(let result):
            return AppStoreConnectError.unauthorized(
                errors: AppStoreConnectError.parseErrorDescription(from: try result.body.json)
            )
        case .undocumented(let statusCode, _):
            return AppStoreConnectError.serverError(
                errorCode: statusCode
            )
        default:
            return AppStoreConnectError.unexpectedError(errors: "\(response)")
        }
    }
    
    /// Handles error responses returned by the App Store Connect API when fetching app store versions.
    /// - Parameter response: The response received from the API.
    /// - Throws: An error of type `AppStoreConnectError` if the response indicates an error.
    private func handleErrors(
        from response: Operations.apps_hyphen_appStoreVersions_hyphen_get_to_many_related.Output
    ) throws -> AppStoreConnectError {
        switch response {
        case .badRequest(let result):
            return AppStoreConnectError.badRequest(
                errors: AppStoreConnectError.parseErrorDescription(from: try result.body.json)
                )
        case .forbidden(let result):
            return AppStoreConnectError.forbidden(
                errors: AppStoreConnectError.parseErrorDescription(from: try result.body.json)
                )
        case .notFound(let result):
            return AppStoreConnectError.notFound(
                errors: AppStoreConnectError.parseErrorDescription(from: try result.body.json)
                )
        case .unauthorized(let result):
            return AppStoreConnectError.unauthorized(
                errors: AppStoreConnectError.parseErrorDescription(from: try result.body.json)
                )
        case .undocumented(let statusCode, _):
            return AppStoreConnectError.serverError(errorCode: statusCode)
            
        default:
            return AppStoreConnectError.unexpectedError(errors: "\(response)")
        }
    }
    
    /// Handles error responses returned by the App Store Connect API when fetching app store prerelease versions.
    /// - Parameter response: The response received from the API.
    /// - Throws: An error of type `AppStoreConnectError` if the response indicates an error.
    private func handleErrors(
        from response: Operations.builds_hyphen_get_collection.Output
    ) throws -> AppStoreConnectError {
        switch response {
        case .badRequest(let result):
            return AppStoreConnectError.badRequest(
                errors: AppStoreConnectError.parseErrorDescription(from: try result.body.json)
                )
        case .unauthorized(let result):
            return AppStoreConnectError.unauthorized(
                errors: AppStoreConnectError.parseErrorDescription(from: try result.body.json)
                )
        case .forbidden(let result):
            return AppStoreConnectError.forbidden(
                errors: AppStoreConnectError.parseErrorDescription(from: try result.body.json)
                )
        default:
            return AppStoreConnectError.unexpectedError(errors: "\(response)")
        }
    }
}
