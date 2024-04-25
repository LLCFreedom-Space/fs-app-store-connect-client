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
//  PayloadTests.swift
//
//
//  Created by Mykola Vasyk on 23.04.2024.
//

import XCTest
import JWTKit
@testable import AppStoreConnectClient

final class PayloadTests: XCTestCase {
    func testPayload() {
        let expiration = Date()
        let expirationClaim = ExpirationClaim(value: expiration)
        let payload = AuthenticationMiddleware.Payload(
            issueID: "issueID",
            expiration: expirationClaim,
            audience: "audience"
        )
        XCTAssertEqual(payload.issueID, "issueID")
        XCTAssertEqual(payload.expiration, expirationClaim)
        XCTAssertEqual(payload.audience, "audience")
    }
}
