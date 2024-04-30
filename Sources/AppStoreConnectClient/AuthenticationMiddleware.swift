//
//  AuthenticationMiddleware.swift
//
//
//  Created by Mykola Vasyk on 22.04.2024.
//

import OpenAPIRuntime
import Foundation
import HTTPTypes
import Crypto

/// Struct representing Authentication Middleware conforming to ClientMiddleware protocol
package struct AuthenticationMiddleware: ClientMiddleware {
    /// The credentials required for generating JWT.
    var credentials: Credentials?
    var cachedToken: String?

    /// Intercepts an outgoing HTTP request and an incoming HTTP response.
    /// - Parameters:
    ///   - request: An HTTP request.
    ///   - body: An HTTP request body.
    ///   - baseURL: A server base URL.
    ///   - operationID: The identifier of the OpenAPI operation.
    ///   - next: A closure that calls the next middleware, or the transport.
    /// - Returns: An HTTP response and its body.
    /// - Throws: An error if interception of the request and response fails.
    package func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var request = request
        guard let credentials = credentials else {
            throw AppStoreConnectError.noHaveCredentials
        }
        let jwt = try createJWT(credentials)
        request.headerFields[.authorization] = "Bearer \(jwt)"
        return try await next(request, body, baseURL)
    }
    
    /// Creates a JWT (JSON Web Token) using the provided credentials.
        /// - Parameter credentials: The App Store Connect credentials.
        /// - Returns: A JWT string.
        /// - Throws: An error if JWT signing fails or credentials are invalid.
    func createJWT(_ credentials: Credentials) throws -> String {
        let privateKey = try JWT.PrivateKey(pemRepresentation: credentials.privateKey)
        var jwt = JWT(keyID: credentials.keyId, privateKey: privateKey, issuerIdentifier: credentials.issuerId, expireDuration: 20 * 60)
        return try jwt.getToken()
    }
}
