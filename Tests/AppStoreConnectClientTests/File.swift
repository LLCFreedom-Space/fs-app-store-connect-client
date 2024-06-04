//
//  File.swift
//  
//
//  Created by Mykola Vasyk on 28.05.2024.
//

import Foundation
import XCTest
@testable import AppStoreConnectClient

final class ASCClientIntegrationTests: XCTestCase {
    var fetchedApps: [Application] = []
    
    func testFetchApps() async throws {
        let credentials = Credentials(
            issuerId: "5c68ecff-1290-499e-b8c2-193996025dc2",
            keyId: "ULCKU69GDY",
            privateKey:
            """
            -----BEGIN PRIVATE KEY-----
            MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgX6js0tmnxknIV+w0
            eLfoDF2fnng+GESiHP6fmTKMMEugCgYIKoZIzj0DAQehRANCAASQpzpdWKT1n4YG
            i8jYKh1w/iNojELO+4RWUSZ5zceH5HdExSKWec/UOXImcpnN5alC98tcmxf7GNRe
            bXp8F8EX
            -----END PRIVATE KEY-----
            """,
            expireDuration: 600
        )
        let client = try AppStoreConnectClient(with: credentials)
        let fetchedApps = try await client.fetchApps()
        print("\(fetchedApps)")
        XCTAssertEqual(fetchedApps.count, 5)
        XCTAssertNotNil(fetchedApps.description)
    }
    
    func testFetchVersions() async throws {
        let credentials = Credentials(
            issuerId: "5c68ecff-1290-499e-b8c2-193996025dc2",
            keyId: "ULCKU69GDY",
            privateKey:
            """
            -----BEGIN PRIVATE KEY-----
            MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgX6js0tmnxknIV+w0
            eLfoDF2fnng+GESiHP6fmTKMMEugCgYIKoZIzj0DAQehRANCAASQpzpdWKT1n4YG
            i8jYKh1w/iNojELO+4RWUSZ5zceH5HdExSKWec/UOXImcpnN5alC98tcmxf7GNRe
            bXp8F8EX
            -----END PRIVATE KEY-----
            """,
            expireDuration: 10
        )
        let client = try AppStoreConnectClient(with: credentials)
        let apps = try await client.fetchApps()
        guard let app = apps.first(where: {$0.bundleId == "com.freedomspace.dealogx"}) else {
            return XCTFail()
        }
        let releases = try await client.fetchVersions(for: app)
        XCTAssertEqual(18, releases.count)
    }
    
    func testFetchBuildVersions() async throws {
        let credentials = Credentials(
            issuerId: "5c68ecff-1290-499e-b8c2-193996025dc2",
            keyId: "ULCKU69GDY",
            privateKey:
            """
            -----BEGIN PRIVATE KEY-----
            MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgX6js0tmnxknIV+w0
            eLfoDF2fnng+GESiHP6fmTKMMEugCgYIKoZIzj0DAQehRANCAASQpzpdWKT1n4YG
            i8jYKh1w/iNojELO+4RWUSZ5zceH5HdExSKWec/UOXImcpnN5alC98tcmxf7GNRe
            bXp8F8EX
            -----END PRIVATE KEY-----
            """,
            expireDuration: 10
        )
        let client = try AppStoreConnectClient(with: credentials)
        let apps = try await client.fetchApps()
        print("<<< apps = \(apps)")
        guard let app = apps.first(where: {$0.bundleId == "com.freedomspace.dealogx"}) else {
            return XCTFail()
        }
        print("<<< app = \(app)")
        let releases = try await client.fetchBuildVersions()
        XCTAssertEqual(18, releases.count)
    }
}

