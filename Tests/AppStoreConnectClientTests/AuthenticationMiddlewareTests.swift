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
import JWTKit
import OpenAPIRuntime
@testable import AppStoreConnectClient

final class AuthenticationMiddlewareTests: XCTestCase {
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
