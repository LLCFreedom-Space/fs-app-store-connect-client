//
//  AuthenticationMiddlewareTests.swift
//
//
//  Created by Mykola Vasyk on 23.04.2024.
//

import XCTest
import OpenAPIRuntime
import Crypto
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
    
    func testGetToken() async throws {
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
            """, 
            expireDuration: 10
        )
        let authenticationMiddleware = AuthenticationMiddleware(credentials: credentials)
        let token = try await authenticationMiddleware.getToken()
        XCTAssertNoThrow(token)
        XCTAssertNotNil(token)
        let cachedToken = try await authenticationMiddleware.getToken()
        XCTAssertNoThrow(cachedToken)
        XCTAssertNotNil(cachedToken)
        XCTAssertEqual(token, cachedToken)
    }
    
    func testGetTokenInvalidPrivateKey() async throws {
        let credentials = Credentials(
            issuerId: UUID().uuidString,
            keyId: UUID().uuidString,
            privateKey:
            """
            MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgX6js0tmnxknIV+w0
            eLfoDF2fnng+GESiHP6fmTKMMEugCgYIKoZIzj0DAQehRANCAASQpzpdWKT1n4YG
            i8jYKh1w/iNojELO+4RWUSZ5zceH5HdExSKWec/UOXImcpnN5alC98tcmxf7GNRe
            bXp8F8EX
            """, 
            expireDuration: 10
        )
        let authenticationMiddleware = AuthenticationMiddleware(credentials: credentials)
        do {
            _ = try await authenticationMiddleware.getToken()
            XCTFail("Expected error not thrown")
        } catch {
            XCTAssertEqual(error.localizedDescription, AppStoreConnectError.invalidPrivateKey.localizedDescription)
        }
    }
}
