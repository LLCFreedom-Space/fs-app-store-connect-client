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
