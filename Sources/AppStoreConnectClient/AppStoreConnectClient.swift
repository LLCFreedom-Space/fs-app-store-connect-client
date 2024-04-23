// The Swift Programming Language
// https://docs.swift.org/swift-book

import OpenAPIURLSession
import Foundation

public final class AppStoreConnectClient {
    private let client: any APIProtocol
    
    init(client: any APIProtocol) {
        self.client = client
    }
    
    public init(with credentials: AppStoreConnectCredentials) throws {
        self.client = try Client(
            serverURL: Servers.server1(),
            transport: URLSessionTransport(),
            middlewares: [
                JWTMiddleware(credentials: credentials),
            ]
        )
    }

    /// Fetches information about an app based on its bundle ID, JW-Token and optional country code.
    ///
    /// - Parameters:
    ///   - bundleId: The unique identifier of the app in the App Store.
    ///   - jwt: The secure key for access to App Store.
    ///   - countryCode: The two-letter code representing the country to search in (optional). Defaults to nil.
    /// - Throws:
    ///   - AppStoreConnectError: An error that may occur during the request.
    /// - Returns: An `AppStoreAppInfo` object containing details about the retrieved app.
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
    
    public func fetchVersions(for app: App) async throws -> [Release] {
        let response = try await client.apps_hyphen_appStoreVersions_hyphen_get_to_many_related(path: .init(id: app.id))
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
