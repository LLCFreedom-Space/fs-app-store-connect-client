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
        let schema = Components.Schemas.AppStoreVersion(_type: .appStoreVersions, id: "",attributes: Components.Schemas.AppStoreVersion.attributesPayload(versionString: "1.2.3", appStoreState: .ACCEPTED))
        let release = Release(schema: schema)
        let state = release?.appStoreState
        let version = release?.version
        XCTAssertEqual(state, "ACCEPTED")
        XCTAssertEqual(version, "1.2.3")
    }
    
    func testReleaseNil() {
        let schema = Components.Schemas.AppStoreVersion(_type: .appStoreVersions, id: "",attributes: Components.Schemas.AppStoreVersion.attributesPayload(versionString: nil, appStoreState: .ACCEPTED))
        let release = Release(schema: schema)
        XCTAssertNil(release)
    }
}
