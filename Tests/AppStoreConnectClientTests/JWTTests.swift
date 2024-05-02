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
//  JWTTests.swift
//
//
//  Created by Mykola Vasyk on 23.04.2024.
//

import XCTest
import Foundation
@testable import AppStoreConnectClient

final class JWTTests: XCTestCase {
    func testVerifyNotExpiredSuccess() throws {
        let privateKey = """
            -----BEGIN PRIVATE KEY-----
            MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgevZzL1gdAFr88hb2
            OF/2NxApJCzGCEDdfSp6VQO30hyhRANCAAQRWz+jn65BtOMvdyHKcvjBeBSDZH2r
            1RTwjmYSi9R/zpBnuQ4EiMnCqfMPWiZqB4QdbAd0E7oH50VpuZ1P087G
            -----END PRIVATE KEY-----
            """
        let credentials = Credentials(
            issuerId: UUID().uuidString,
            keyId: UUID().uuidString,
            privateKey: privateKey,
            expireDuration: 2
        )
        let jwt = try JWT.createToken(by: credentials)
        let result = JWT.verifyNotExpired(jwt)
        XCTAssertTrue(result)
    }
    
    func testVerifyNotExpiredFailed() throws {
        let privateKey = """
            -----BEGIN PRIVATE KEY-----
            MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgevZzL1gdAFr88hb2
            OF/2NxApJCzGCEDdfSp6VQO30hyhRANCAAQRWz+jn65BtOMvdyHKcvjBeBSDZH2r
            1RTwjmYSi9R/zpBnuQ4EiMnCqfMPWiZqB4QdbAd0E7oH50VpuZ1P087G
            -----END PRIVATE KEY-----
            """
        let credentials = Credentials(
            issuerId: UUID().uuidString,
            keyId: UUID().uuidString,
            privateKey: privateKey,
            expireDuration: -1
        )
        let jwt = try JWT.createToken(by: credentials)
        let result = JWT.verifyNotExpired(jwt)
        XCTAssertFalse(result)
    }
    
    func testInvalidPartCount() throws {
        let privateKey = """
            -----BEGIN PRIVATE KEY-----
            MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgevZzL1gdAFr88hb2
            OF/2NxApJCzGCEDdfSp6VQO30hyhRANCAAQRWz+jn65BtOMvdyHKcvjBeBSDZH2r
            1RTwjmYSi9R/zpBnuQ4EiMnCqfMPWiZqB4QdbAd0E7oH50VpuZ1P087G
            -----END PRIVATE KEY-----
            """
        let credentials = Credentials(
            issuerId: UUID().uuidString,
            keyId: UUID().uuidString,
            privateKey: privateKey,
            expireDuration: 2
        )
        let jwt = try JWT.createToken(by: credentials)
        var parts = jwt.components(separatedBy: ".")
        let resultParts = parts.remove(at: 0)
        let result = JWT.verifyNotExpired(resultParts)
        XCTAssertFalse(result)
    }
    
    func testInvalidPayloadDecode() throws {
        let privateKey = """
            -----BEGIN PRIVATE KEY-----
            MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgevZzL1gdAFr88hb2
            OF/2NxApJCzGCEDdfSp6VQO30hyhRANCAAQRWz+jn65BtOMvdyHKcvjBeBSDZH2r
            1RTwjmYSi9R/zpBnuQ4EiMnCqfMPWiZqB4QdbAd0E7oH50VpuZ1P087G
            -----END PRIVATE KEY-----
            """
        let credentials = Credentials(
            issuerId: UUID().uuidString,
            keyId: UUID().uuidString,
            privateKey: privateKey,
            expireDuration: 2
        )
        let jwt = try JWT.createToken(by: credentials)
        let index = 1
        let takenСharacter = jwt.prefix(index)
        let resultReplacing = jwt.replacingOccurrences(of: takenСharacter, with: "*")
        let result = JWT.verifyNotExpired(resultReplacing)
        XCTAssertFalse(result)
    }
}
