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
    
    func testPreReleaseVersionNil() {
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
