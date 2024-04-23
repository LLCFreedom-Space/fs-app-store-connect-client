//
//  JWTMiddleware.swift
//  
//
//  Created by Mykola Vasyk on 22.04.2024.
//

import OpenAPIRuntime
import Foundation
import HTTPTypes
import JWTKit

struct JWTMiddleware: ClientMiddleware {
    let credentials: AppStoreConnectCredentials
    
    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var request = request
        let jwt = try createJWT(credentials)
        request.headerFields[.authorization] = "Bearer \(jwt)"
        return try await next(request, body, baseURL)
    }
    
    func createJWT(_ credentials: AppStoreConnectCredentials) throws -> String {
        guard let signer = try? JWTSigner.es256(
            key: ECDSAKey.private(pem: credentials.privateKey))
        else {
            throw AppStoreConnectError.invalidJWT
        }
        
        let payload = Payload(
            issueID: IssuerClaim(value: credentials.issuerId),
            expiration: ExpirationClaim(
                value: Date(
                    timeInterval: 2 * 60,
                    since: Date()
                )
            ),
            audience: AudienceClaim(
                value: "appstoreconnect-v1"
            )
        )
        
        guard let jwt = try? signer.sign(
            payload,
            kid: JWKIdentifier(string: credentials.privateKeyId)
        ) else {
            throw AppStoreConnectError.invalidJWT
        }
        
        return jwt
    }
}
