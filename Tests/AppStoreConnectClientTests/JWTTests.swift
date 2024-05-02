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
            MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgX6js0tmnxknIV+w0
            eLfoDF2fnng+GESiHP6fmTKMMEugCgYIKoZIzj0DAQehRANCAASQpzpdWKT1n4YG
            i8jYKh1w/iNojELO+4RWUSZ5zceH5HdExSKWec/UOXImcpnN5alC98tcmxf7GNRe
            bXp8F8EX
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
            MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgX6js0tmnxknIV+w0
            eLfoDF2fnng+GESiHP6fmTKMMEugCgYIKoZIzj0DAQehRANCAASQpzpdWKT1n4YG
            i8jYKh1w/iNojELO+4RWUSZ5zceH5HdExSKWec/UOXImcpnN5alC98tcmxf7GNRe
            bXp8F8EX
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
            MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgX6js0tmnxknIV+w0
            eLfoDF2fnng+GESiHP6fmTKMMEugCgYIKoZIzj0DAQehRANCAASQpzpdWKT1n4YG
            i8jYKh1w/iNojELO+4RWUSZ5zceH5HdExSKWec/UOXImcpnN5alC98tcmxf7GNRe
            bXp8F8EX
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
            MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgX6js0tmnxknIV+w0
            eLfoDF2fnng+GESiHP6fmTKMMEugCgYIKoZIzj0DAQehRANCAASQpzpdWKT1n4YG
            i8jYKh1w/iNojELO+4RWUSZ5zceH5HdExSKWec/UOXImcpnN5alC98tcmxf7GNRe
            bXp8F8EX
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

