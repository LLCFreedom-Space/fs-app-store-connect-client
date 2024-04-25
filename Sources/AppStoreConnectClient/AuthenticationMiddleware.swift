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
import JWTKit

/// Struct representing Authentication Middleware conforming to ClientMiddleware protocol
package struct AuthenticationMiddleware: ClientMiddleware {
    /// Represents a payload structure conforming to the JWTPayload protocol.
    /// This structure contains claims related to JWT such as issuer, expiration, and audience.
     struct Payload: JWTPayload {
        /// Represents the issuer claim.
        var issueID: IssuerClaim
        /// Represents the expiration claim.
        var expiration: ExpirationClaim
        /// Represents the audience claim.
        var audience: AudienceClaim
        
        /// Verifies the payload using the provided JWTSigner.
        /// - Parameter signer: The JWTSigner instance used for verification.
        /// - Throws: Throws an error if the payload verification fails.
        func verify(using signer: JWTSigner) throws {
            try expiration.verifyNotExpired()
        }
        
        /// Coding keys for encoding and decoding the payload.
        private enum CodingKeys: String, CodingKey {
            case issueID = "iss"
            case expiration = "exp"
            case audience = "aud"
        }
    }
    
    /// The credentials required for generating JWT.
    var credentials: Credentials?
    
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
        let signers = JWTSigners()
        do {
            try signers.use(.es256(key: .private(pem: credentials.privateKey)))
        } catch {
            throw AppStoreConnectError.invalidPrivateKey
        }
        let jwkID = JWKIdentifier(string: credentials.keyId)
        let issuer = IssuerClaim(value: credentials.issuerId)
        let payload = Payload(
            issueID: issuer,
            expiration: ExpirationClaim(
                value: Date(
                    timeInterval: 2 * 60,
                    since: Date()
                )
            ),
            audience: AudienceClaim(value: "appstoreconnect-v1")
        )
        guard let jwt = try? signers.sign(payload, kid: jwkID) else {
            throw AppStoreConnectError.invalidSign
        }
        return jwt
    }
}
