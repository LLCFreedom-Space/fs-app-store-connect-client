// The Swift Programming Language
// https://docs.swift.org/swift-book

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
    public init(with credentials: AppStoreConnectCredentials) throws {
        self.client = try Client(
            serverURL: Servers.server1(),
            transport: URLSessionTransport(),
            middlewares: [
                JWTMiddleware(credentials: credentials),
            ]
        )
    }
    
    /// Fetches collection of apps from the App Store Connect API.
    /// - Returns: An array of `App` objects.
    /// - Throws: An error if the fetch operation fails.
    public func fetchApps() async throws -> [App] {
        let response = try await client.apps_hyphen_get_collection()
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let json):
                return json.data.compactMap({ App(schema: $0) })
            }
        case .badRequest(_):
            throw AppStoreConnectError.badRequest
        case .forbidden(_):
            throw AppStoreConnectError.forbidden
        case .unauthorized(_):
            throw AppStoreConnectError.unauthorized
        case .undocumented(let statusCode, _):
            throw AppStoreConnectError.serverError(errorCode: statusCode)
        }
    }
    
    /// Fetches a collection of versions for a specified app from the App Store Connect API.
    /// - Parameter app: The app for which to fetch versions.
    /// - Returns: An array of `Release` objects.
    /// - Throws: An error if the fetch operation fails.
    public func fetchVersions(for app: App) async throws -> [Release] {
        let response = try await client.apps_hyphen_appStoreVersions_hyphen_get_to_many_related(
            path: .init(id: app.id)
        )
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let json):
                return json.data.compactMap({ Release(schema: $0) })
            }
        case .badRequest(_):
            throw AppStoreConnectError.badRequest
        case .forbidden(_):
            throw AppStoreConnectError.forbidden
        case .notFound(_):
            throw AppStoreConnectError.notFound
        case .unauthorized(_):
            throw AppStoreConnectError.unauthorized
        case .undocumented(let statusCode, _):
            throw AppStoreConnectError.serverError(errorCode: statusCode)
        }
    }
}
