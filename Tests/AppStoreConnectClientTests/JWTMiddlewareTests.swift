//
//  JWTMiddlewareTests.swift
//
//
//  Created by Mykola Vasyk on 23.04.2024.
//

import XCTest
import JWTKit
import OpenAPIRuntime
@testable import AppStoreConnectClient

final class JWTMiddlewareTests: XCTestCase {
    func testCreateJWT() throws {
        let credentials = AppStoreConnectCredentials(
            issuerId: UUID().uuidString,
            privateKeyId: UUID().uuidString,
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
        let jWTMiddleware = JWTMiddleware()
        let token = try jWTMiddleware.createJWT(credentials)
        XCTAssertNoThrow(token)
        XCTAssertNotNil(token)
    }
    
    func testCreateJWTInvalidPrivateKey() throws {
        let credentials = AppStoreConnectCredentials(
            issuerId: UUID().uuidString,
            privateKeyId: UUID().uuidString,
            privateKey:
            """
            MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgX6js0tmnxknIV+w0
            eLfoDF2fnng+GESiHP6fmTKMMEugCgYIKoZIzj0DAQehRANCAASQpzpdWKT1n4YG
            i8jYKh1w/iNojELO+4RWUSZ5zceH5HdExSKWec/UOXImcpnN5alC98tcmxf7GNRe
            bXp8F8EX
            """
        )
        let jWTMiddleware = JWTMiddleware()
        XCTAssertThrowsError(try jWTMiddleware.createJWT(credentials)) { error in
            XCTAssertEqual(error as? AppStoreConnectError, .invalidPrivateKey)
        }
    }
}

