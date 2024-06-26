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
//  CredentialsTests.swift
//
//
//  Created by Mykola Vasyk on 23.04.2024.
//

import XCTest
@testable import AppStoreConnectClient

final class CredentialsTests: XCTestCase {
    func testCredentials() {
        let сredentials = Credentials(
            issuerId: "issuerId",
            keyId: "keyId",
            privateKey: "privateKey", 
            expireDuration: 1
        )
        XCTAssertEqual(сredentials.issuerId, "issuerId")
        XCTAssertEqual(сredentials.keyId, "keyId")
        XCTAssertEqual(сredentials.privateKey, "privateKey")
    }
}
