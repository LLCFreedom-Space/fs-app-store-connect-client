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
    func testGetToken() async throws {
        let credentials = Credentials(
            issuerId: UUID().uuidString,
            keyId: UUID().uuidString,
            privateKey:
            """
            -----BEGIN PRIVATE KEY-----
            MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgevZzL1gdAFr88hb2
            OF/2NxApJCzGCEDdfSp6VQO30hyhRANCAAQRWz+jn65BtOMvdyHKcvjBeBSDZH2r
            1RTwjmYSi9R/zpBnuQ4EiMnCqfMPWiZqB4QdbAd0E7oH50VpuZ1P087G
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
            MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgevZzL1gdAFr88hb2
            OF/2NxApJCzGCEDdfSp6VQO30hyhRANCAAQRWz+jn65BtOMvdyHKcvjBeBSDZH2r
            1RTwjmYSi9R/zpBnuQ4EiMnCqfMPWiZqB4QdbAd0E7oH50VpuZ1P087G
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
