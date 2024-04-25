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
//  ApplicationTests.swift
//
//
//  Created by Mykola Vasyk on 24.04.2024.
//

import XCTest
@testable import AppStoreConnectClient

class ApplicationTests: XCTestCase {
    func testInitWithValidSchema() {
        let schema = Components.Schemas.App(
            _type: .apps,
            id: "1234567",
            attributes: .init(bundleId: "com.example.app")
        )
        let app = Application(schema: schema)
        XCTAssertNotNil(app)
        XCTAssertEqual(app?.id, "1234567")
        XCTAssertEqual(app?.bundleID, "com.example.app")
    }
    
    func testInitWithInvalidSchema() {
        let schema = Components.Schemas.App(
            _type: .apps,
            id: "1234567",
            attributes: nil
        )
        let app = Application(schema: schema)
        XCTAssertNil(app)
    }
}
