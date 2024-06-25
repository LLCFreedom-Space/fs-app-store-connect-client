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
//  ReleaseTests.swift
//
//
//  Created by Mykola Vasyk on 23.04.2024.
//

import XCTest
@testable import AppStoreConnectClient

final class ReleaseTests: XCTestCase {
    func testRelease() {
        let schema = Components.Schemas.AppStoreVersion(
            _type: .appStoreVersions,
            id: "",
            attributes: Components.Schemas.AppStoreVersion.attributesPayload(
                versionString: "1.2.3",
                appStoreState: .ACCEPTED
            )
        )
        let release = Release(schema: schema)
        let state = release?.appStoreState
        let version = release?.version
        XCTAssertEqual(state, "ACCEPTED")
        XCTAssertEqual(version, "1.2.3")
    }
    
    func testReleaseNil() {
        let schema = Components.Schemas.AppStoreVersion(
            _type: .appStoreVersions,
            id: "",
            attributes: Components.Schemas.AppStoreVersion.attributesPayload(
                versionString: nil,
                appStoreState: .ACCEPTED
            )
        )
        let release = Release(schema: schema)
        XCTAssertNil(release)
    }
    
    func testReleaseInitializer() {
        let version = "mock-3.0.0"
        let appStoreState = "mock-Ready for Sale"
        let release = Release(version: version, appStoreState: appStoreState)
        XCTAssertEqual(release.version, version)
        XCTAssertEqual(release.appStoreState, appStoreState)
    }
}
