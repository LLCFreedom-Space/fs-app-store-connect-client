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
