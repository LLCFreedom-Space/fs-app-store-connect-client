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
