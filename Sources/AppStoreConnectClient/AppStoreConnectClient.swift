//
//  Application.swift
//
//
//  Created by Mykola Vasyk on 22.04.2024.
//

import OpenAPIURLSession
import Foundation

/// The client for interacting with the App Store Connect API.
public final class AppStoreConnectClient {
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
                AuthenticationMiddleware()
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
        case .badRequest(let result):
            throw AppStoreConnectError.badRequest
        case .forbidden(let result):
            throw AppStoreConnectError.forbidden
        case .unauthorized(let result):
            throw AppStoreConnectError.unauthorized
        case .undocumented(let statusCode, _):
            throw AppStoreConnectError.serverError(errorCode: statusCode)
        }
    }
    
    /// Fetches a collection of versions for a specified app from the App Store Connect API.
    /// - Parameter app: The app for which to fetch versions.
    /// - Returns: An array of `Release` objects.
    /// - Throws: An error if the fetch operation fails.
    public func fetchVersions(for app: Application) async throws -> [Release] {
        let response = try await client.apps_hyphen_appStoreVersions_hyphen_get_to_many_related(
            path: .init(id: app.id)
        )
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let json):
                return json.data.compactMap({ Release(schema: $0) })
            }
        case .badRequest(let result):
            throw AppStoreConnectError.badRequest
        case .forbidden(let result):
            throw AppStoreConnectError.forbidden
        case .notFound(let result):
            throw AppStoreConnectError.notFound
        case .unauthorized(let result):
            throw AppStoreConnectError.unauthorized
        case .undocumented(let statusCode, _):
            throw AppStoreConnectError.serverError(errorCode: statusCode)
        }
    }
}
