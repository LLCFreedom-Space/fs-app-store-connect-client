//
//  AuthenticationMiddlewareTests.swift
//
//
//  Created by Mykola Vasyk on 23.04.2024.
//

import XCTest
import JWTKit
import OpenAPIRuntime
@testable import AppStoreConnectClient

final class AuthenticationMiddlewareTests: XCTestCase {
//    func testPayload() {
//        let expiration = Date()
//        let expirationClaim = ExpirationClaim(value: expiration)
//        let payload = Payload(
//            expiration: "issueID",
//            issuerId: expirationClaim,
//            issuedAt: "audience", 
//            audience: <#String?#>
//        )
//        XCTAssertEqual(payload.issueID, "issueID")
//        XCTAssertEqual(payload.expiration, expirationClaim)
//        XCTAssertEqual(payload.audience, "audience")
//    }
    
    func testCreateJWT() throws {
        let credentials = Credentials(
            issuerId: UUID().uuidString,
            keyId: UUID().uuidString,
            privateKey:
            """
            -----BEGIN PRIVATE KEY-----
            MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgX6js0tmnxknIV+w0
            eLfoDF2fnng+GESiHP6fmTKMMEugCgYIKoZIzj0DAQehRANCAASQpzpdWKT1n4YG
            i8jYKh1w/iNojELO+4RWUSZ5zceH5HdExSKWec/UOXImcpnN5alC98tcmxf7GNRe
            bXp8F8EX
            -----END PRIVATE KEY-----
            """
        )
        let authenticationMiddleware = AuthenticationMiddleware()
        let token = try authenticationMiddleware.createJWT(credentials)
        XCTAssertNoThrow(token)
        XCTAssertNotNil(token)
    }
    
    func testCreateJWTInvalidPrivateKey() throws {
        let credentials = Credentials(
            issuerId: UUID().uuidString,
            keyId: UUID().uuidString,
            privateKey:
            """
            MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgX6js0tmnxknIV+w0
            eLfoDF2fnng+GESiHP6fmTKMMEugCgYIKoZIzj0DAQehRANCAASQpzpdWKT1n4YG
            i8jYKh1w/iNojELO+4RWUSZ5zceH5HdExSKWec/UOXImcpnN5alC98tcmxf7GNRe
            bXp8F8EX
            """
        )
        let authenticationMiddleware = AuthenticationMiddleware()
        XCTAssertThrowsError(try authenticationMiddleware.createJWT(credentials)) { error in
            XCTAssertEqual(error as? AppStoreConnectError, .invalidPrivateKey)
        }
    }
}
