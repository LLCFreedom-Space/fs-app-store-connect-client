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
    /// The cached JWT token.
    private var cachedToken: String?
    
    /// Initializes the authentication middleware with the provided credentials.
    /// - Parameter credentials: The credentials required for authentication.
    package init(credentials: Credentials) {
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
    
    /// Retrieves a valid JWT token.
    /// - Returns: A valid JWT token.
    /// - Throws: An error if token retrieval fails.
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
