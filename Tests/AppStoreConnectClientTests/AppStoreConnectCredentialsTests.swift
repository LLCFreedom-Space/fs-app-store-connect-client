//
//  AppStoreConnectCredentialsTests.swift
//  
//
//  Created by Mykola Vasyk on 23.04.2024.
//

import XCTest
@testable import AppStoreConnectClient

final class AppStoreConnectCredentialsTests: XCTestCase {
    func testAppStoreConnectCredentials() {
        let appStoreConnectCredentials = AppStoreConnectCredentials(issuerId: "issuerId", privateKeyId: "privateKeyId", privateKey: "privateKey")
        XCTAssertEqual(appStoreConnectCredentials.issuerId, "issuerId")
        XCTAssertEqual(appStoreConnectCredentials.privateKeyId, "privateKeyId")
        XCTAssertEqual(appStoreConnectCredentials.privateKey, "privateKey")
    }
}
