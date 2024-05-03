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
//  AppStoreConnectClientTests.swift
//
//
//  Created by Mykola Vasyk on 22.04.2024.
//

import XCTest
@testable import AppStoreConnectClient

final class AppStoreConnectClientTests: XCTestCase {
    func testFetchAppsSuccess() async throws {
        var mockClient = MockAPIClient()
        mockClient.result = .ok
        let client = AppStoreConnectClient(client: mockClient)
        let apps = try await client.fetchApps()
        XCTAssertEqual(1, apps.count)
        XCTAssertEqual("1234567", apps.first?.id)
        XCTAssertEqual("com.example.app", apps.first?.bundleId)
    }
    
    func testFetchAppsBadRequest() async throws {
        var mockClient = MockAPIClient()
        mockClient.result = .badRequest
        let client = AppStoreConnectClient(client: mockClient)
        
        do {
            _ = try await client.fetchApps()
            XCTFail("Expected error not thrown")
        } catch {
            XCTAssertEqual(AppStoreConnectError.badRequest.localizedDescription, error.localizedDescription)
        }
    }
    
    func testFetchAppsForbidden() async throws {
        var mockClient = MockAPIClient()
        mockClient.result = .forbidden
        let client = AppStoreConnectClient(client: mockClient)
        
        do {
            _ = try await client.fetchApps()
            XCTFail("Expected error not thrown")
        } catch {
            XCTAssertEqual(AppStoreConnectError.forbidden.localizedDescription, error.localizedDescription)
        }
    }
    
    func testFetchAppsUnauthorized() async throws {
        var mockClient = MockAPIClient()
        mockClient.result = .unauthorized
        let client = AppStoreConnectClient(client: mockClient)
        
        do {
            _ = try await client.fetchApps()
            XCTFail("Expected error not thrown")
        } catch {
            XCTAssertEqual(AppStoreConnectError.unauthorized.localizedDescription, error.localizedDescription)
        }
    }
    
    func testFetchAppsUndocumented() async throws {
        var mockClient = MockAPIClient()
        mockClient.result = .undocumented
        let client = AppStoreConnectClient(client: mockClient)
        
        do {
            _ = try await client.fetchApps()
            XCTFail("Expected error not thrown")
        } catch {
            let errorCode = 501
            XCTAssertEqual(AppStoreConnectError.serverError(errorCode: errorCode).localizedDescription, error.localizedDescription)
        }
    }
    
    func testFetchVersionsSuccess() async throws {
        var mockClient = MockAPIClient()
        mockClient.result = .ok
        let client = AppStoreConnectClient(client: mockClient)
        let app = Application(id: "", bundleId: "")
        let apps = try await client.fetchVersions(for: app)
        XCTAssertEqual(1, apps.count)
        XCTAssertEqual(apps.first?.appStoreState, "ACCEPTED")
        XCTAssertEqual(apps.first?.version, "1.1.1")
    }
    
    func testFetchVersionsBadRequest() async throws {
        var mockClient = MockAPIClient()
        mockClient.result = .badRequest
        let client = AppStoreConnectClient(client: mockClient)
        let app = Application(id: "", bundleId: "")
        do {
            _ = try await client.fetchVersions(for: app)
            XCTFail("Expected error not thrown")
        } catch {
            XCTAssertEqual(AppStoreConnectError.badRequest.localizedDescription, error.localizedDescription)
        }
    }
    
    func testFetchVersionsForbidden() async throws {
        var mockClient = MockAPIClient()
        mockClient.result = .forbidden
        let client = AppStoreConnectClient(client: mockClient)
        let app = Application(id: "", bundleId: "")
        do {
            _ = try await client.fetchVersions(for: app)
            XCTFail("Expected error not thrown")
        } catch {
            XCTAssertEqual(AppStoreConnectError.forbidden.localizedDescription, error.localizedDescription)
        }
    }
    
    func testFetchVersionsNotFound() async throws {
        var mockClient = MockAPIClient()
        mockClient.result = .notFound
        let client = AppStoreConnectClient(client: mockClient)
        let app = Application(id: "", bundleId: "")
        do {
            _ = try await client.fetchVersions(for: app)
            XCTFail("Expected error not thrown")
        } catch {
            XCTAssertEqual(AppStoreConnectError.notFound.localizedDescription, error.localizedDescription)
        }
    }
    
    func testFetchVersionsUnauthorized() async throws {
        var mockClient = MockAPIClient()
        mockClient.result = .unauthorized
        let client = AppStoreConnectClient(client: mockClient)
        let app = Application(id: "", bundleId: "")
        do {
            _ = try await client.fetchVersions(for: app)
            XCTFail("Expected error not thrown")
        } catch {
            XCTAssertEqual(AppStoreConnectError.unauthorized.localizedDescription, error.localizedDescription)
        }
    }
    
    func testFetchVersionsUndocumented() async throws {
        var mockClient = MockAPIClient()
        mockClient.result = .undocumented
        let client = AppStoreConnectClient(client: mockClient)
        let app = Application(id: "", bundleId: "")
        do {
            _ = try await client.fetchVersions(for: app)
            XCTFail("Expected error not thrown")
        } catch {
            let errorCode = 501
            XCTAssertEqual(AppStoreConnectError.serverError(errorCode: errorCode).localizedDescription, error.localizedDescription)
        }
    }
}
