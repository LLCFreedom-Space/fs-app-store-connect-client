//
//  PayloadTests.swift
//
//
//  Created by Mykola Vasyk on 23.04.2024.
//

import XCTest
import JWTKit
@testable import AppStoreConnectClient

final class PayloadTests: XCTestCase {
    func testPayload() {
        let expiration = Date()
        let expirationClaim = ExpirationClaim(value: expiration)
        let payload = Payload(
            issueID: "issueID",
            expiration: expirationClaim,
            audience: "audience"
        )
        XCTAssertEqual(payload.issueID, "issueID")
        XCTAssertEqual(payload.expiration, expirationClaim)
        XCTAssertEqual(payload.audience, "audience")
    }
}
