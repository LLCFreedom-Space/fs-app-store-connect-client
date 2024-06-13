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
//  PreReleaseVersionTest.swift
//
//
//  Created by Mykola Vasyk on 10.06.2024.
//

import XCTest
@testable import AppStoreConnectClient

final class PreReleaseVersionTest: XCTestCase {
    func testPreReleaseVersion() {
        let scheme = Components.Schemas.PrereleaseVersionWithoutIncludesResponse(
            data: .init(
                _type: .preReleaseVersions,
                id: "1111-111111-11111111",
                attributes: .init(
                    version: "FooBarBazVersion",
                    platform: .IOS
                ),
                relationships: .none,
                links: .none
            ),
            links: .init(_self: "mockLinks")
        )
        let preReleaseVersion = PreReleaseVersion(schema: scheme)
        XCTAssertEqual(preReleaseVersion.id, "1111-111111-11111111")
        XCTAssertEqual(preReleaseVersion.version, "FooBarBazVersion")
        XCTAssertEqual(preReleaseVersion.platform, "IOS")
    }
    
    func testPreReleaseVersionWithNilAttributes() {
        let scheme = Components.Schemas.PrereleaseVersionWithoutIncludesResponse(
            data: .init(
                _type: .preReleaseVersions,
                id: "1111-111111-11111111",
                attributes: .init(
                    version: nil,
                    platform: nil
                ),
                relationships: .none,
                links: .none
            ),
            links: .init(_self: "mockLinks")
        )
        let preReleaseVersion = PreReleaseVersion(schema: scheme)
        XCTAssertNil(preReleaseVersion.version)
        XCTAssertNil(preReleaseVersion.platform)
    }
}
