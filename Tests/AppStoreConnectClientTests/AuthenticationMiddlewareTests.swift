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
        let seconds: TimeInterval = 10
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
            expireDuration: seconds
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
        let seconds: TimeInterval = 10
        let credentials = Credentials(
            issuerId: UUID().uuidString,
            keyId: UUID().uuidString,
            privateKey:
            """
            MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgevZzL1gdAFr88hb2
            OF/2NxApJCzGCEDdfSp6VQO30hyhRANCAAQRWz+jn65BtOMvdyHKcvjBeBSDZH2r
            1RTwjmYSi9R/zpBnuQ4EiMnCqfMPWiZqB4QdbAd0E7oH50VpuZ1P087G
            """,
            expireDuration: seconds
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
