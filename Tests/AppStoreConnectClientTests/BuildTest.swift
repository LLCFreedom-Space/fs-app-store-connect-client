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
//  BuildTest.swift
//
//
//  Created by Mykola Vasyk on 07.06.2024.
//

import XCTest
@testable import AppStoreConnectClient

final class BuildTest: XCTestCase {
    func testBuild() {
        let dateFormatter = DateFormatter()
        let mockData = dateFormatter.date(from: "2011-11-11 11:11:11 +0000")
        let schema = Components.Schemas.Build(
            _type: .builds,
            id: "1111-111111-11111111",
            attributes: .init(
                version: "FooBarBazVersion",
                uploadedDate: mockData,
                minOsVersion: "FooBarBazMinOs"
            ),
            relationships: .none,
            links: .none
        )
        let build = Build(schema: schema)
        XCTAssertEqual(build.id, "1111-111111-11111111")
        XCTAssertEqual(build.version, "FooBarBazVersion")
        XCTAssertEqual(build.minOsVersion, "FooBarBazMinOs")
        XCTAssertEqual(build.uploadedDate, mockData)
    }
    
    func testBuildInitializationWithNilAttributes() {
        let schema = Components.Schemas.Build(
            _type: .builds,
            id: "1111-111111-11111111",
            attributes: .init(
                version: nil,
                uploadedDate: nil,
                minOsVersion: nil
            ),
            relationships: .none,
            links: .none
        )
        let build = Build(schema: schema)
        XCTAssertNil(build.version)
        XCTAssertNil(build.uploadedDate)
        XCTAssertNil(build.minOsVersion)
    }
}
