//
//  ASCClientIntegrationTests.swift
//
//
//  Created by Mykola Vasyk on 24.04.2024.
//

import XCTest
@testable import AppStoreConnectClient


//final class ASCClientIntegrationTests: XCTestCase {
//    var fetchedApps: [App] = []
//    
//    func testFetchApps() async throws {
//        let credentials = AppStoreConnectCredentials(
//            issuerId: "5c68ecff-1290-499e-b8c2-193996025dc2",
//            privateKeyId: "ULCKU69GDY",
//            privateKey:
//            """
//            -----BEGIN PRIVATE KEY-----
//            MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgX6js0tmnxknIV+w0
//            eLfoDF2fnng+GESiHP6fmTKMMEugCgYIKoZIzj0DAQehRANCAASQpzpdWKT1n4YG
//            i8jYKh1w/iNojELO+4RWUSZ5zceH5HdExSKWec/UOXImcpnN5alC98tcmxf7GNRe
//            bXp8F8EX
//            -----END PRIVATE KEY-----
//            """
//        )
//        let client = try AppStoreConnectClient(with: credentials)
//        let fetchedApps = try await client.fetchApps()
//        print("\(fetchedApps)")
//        XCTAssertEqual(fetchedApps.count, 5)
//        XCTAssertNotNil(fetchedApps.description)
//    }
//    
//    func testFetchVersions() async throws {
//        let credentials = AppStoreConnectCredentials(
//            issuerId: "5c68ecff-1290-499e-b8c2-193996025dc2",
//            privateKeyId: "ULCKU69GDY",
//            privateKey: 
//            """
//            -----BEGIN PRIVATE KEY-----
//            MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgX6js0tmnxknIV+w0
//            eLfoDF2fnng+GESiHP6fmTKMMEugCgYIKoZIzj0DAQehRANCAASQpzpdWKT1n4YG
//            i8jYKh1w/iNojELO+4RWUSZ5zceH5HdExSKWec/UOXImcpnN5alC98tcmxf7GNRe
//            bXp8F8EX
//            -----END PRIVATE KEY-----
//            """
//        )
//        let client = try AppStoreConnectClient(with: credentials)
//        let apps = try await client.fetchApps()
//        guard let app = apps.first(where: {$0.bundleID == "com.freedomspace.dealogx"}) else {
//            return XCTFail()
//        }
//        let releases = try await client.fetchVersions(for: app)
//        XCTAssertEqual(18, releases.count)
//    }
//}
