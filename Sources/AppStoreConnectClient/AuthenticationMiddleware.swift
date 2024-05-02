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
package actor AuthenticationMiddleware: ClientMiddleware {
    /// The credentials required for generating JWT.
    private let credentials: Credentials
    private var cachedToken: String? = nil
    
    init(credentials: Credentials) {
        self.credentials = credentials
    }
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
        let jwt = try getToken()
        request.headerFields[.authorization] = "Bearer \(jwt)"
        return try await next(request, body, baseURL)
    }
    
    func getToken() throws -> String {
        if let cachedToken = cachedToken, JWT.verifyNotExpired(cachedToken) {
            return cachedToken
        } else {
            let newToken = try JWT.createToken(by: credentials)
            cachedToken = newToken
            return newToken
        }
    }
}
