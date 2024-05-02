//
//  JWTTests.swift
//
//
//  Created by Mykola Vasyk on 23.04.2024.
//

import XCTest
@testable import AppStoreConnectClient

//final class JWTTests: XCTestCase {
//    
//    func testVerifyNotExpiredValidToken() throws {
//        let testToken = """
//            -----BEGIN PRIVATE KEY-----
//            MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgX6js0tmnxknIV+w0
//            eLfoDF2fnng+GESiHP6fmTKMMEugCgYIKoZIzj0DAQehRANCAASQpzpdWKT1n4YG
//            i8jYKh1w/iNojELO+4RWUSZ5zceH5HdExSKWec/UOXImcpnN5alC98tcmxf7GNRe
//            bXp8F8EX
//            -----END PRIVATE KEY-----
//            """
//        let futureExpiration = Date().addingTimeInterval(1000)
//        let payload = JWT.Payload(expirationTime: futureExpiration.timeIntervalSince1970, issuerId: UUID().uuidString, issuedAt: Date().timeIntervalSince1970)
//        let isNotExpired = JWT.verifyNotExpired(testToken)
//        XCTAssertTrue(isNotExpired)
//    }
//}

