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
        var mockClient = MockAPIClient(result: .ok)
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
        let text = "\nThe request failed with error response status: 400, error code: BAD_REQUEST, error title: Invalid Input, error detail: The provided data failed validation."
        let expectedError = AppStoreConnectError.badRequest(errors: text)
        do {
            _ = try await client.fetchApps()
            XCTFail("Expected error not thrown")
        } catch {
            if let appStoreConnectError = error as? AppStoreConnectError {
                XCTAssertEqual(appStoreConnectError, expectedError)
            } else {
                XCTFail("Unexpected error type: \(error)")
            }
        }
    }
    
    func testFetchAppsForbidden() async throws {
        var mockClient = MockAPIClient()
        mockClient.result = .forbidden
        let client = AppStoreConnectClient(client: mockClient)
        let text = "\nThe request failed with error response status: 403, error code: FORBIDDEN, error title: Access Denied, error detail: You do not have permission to access this resource."
        let expectedError = AppStoreConnectError.forbidden(errors: text)
        do {
            _ = try await client.fetchApps()
            XCTFail("Expected error not thrown")
        } catch {
            if let appStoreConnectError = error as? AppStoreConnectError {
                XCTAssertEqual(appStoreConnectError, expectedError)
            } else {
                XCTFail("Unexpected error type: \(error)")
            }
        }
    }
    
    func testFetchAppsUnauthorized() async throws {
        var mockClient = MockAPIClient()
        mockClient.result = .unauthorized
        let client = AppStoreConnectClient(client: mockClient)
        let text = "\nThe request failed with error response status: 401, error code: UNAUTHORIZED, error title: Unauthorized, error detail: Authentication credentials were missing or incorrect."
        let expectedError = AppStoreConnectError.unauthorized(errors: text)
        do {
            _ = try await client.fetchApps()
            XCTFail("Expected error not thrown")
        } catch {
            if let appStoreConnectError = error as? AppStoreConnectError {
                XCTAssertEqual(appStoreConnectError, expectedError)
            } else {
                XCTFail("Unexpected error type: \(error)")
            }
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
        let text = "\nThe request failed with error response status: 400, error code: BAD_REQUEST, error title: Invalid Input, error detail: The provided data failed validation."
        let expectedError = AppStoreConnectError.badRequest(errors: text)
        var mockClient = MockAPIClient()
        mockClient.result = .badRequest
        let client = AppStoreConnectClient(client: mockClient)
        let app = Application(id: "", bundleId: "")
        do {
            _ = try await client.fetchVersions(for: app)
            XCTFail("Expected error not thrown")
        } catch {
            if let appStoreConnectError = error as? AppStoreConnectError {
                XCTAssertEqual(appStoreConnectError, expectedError)
            } else {
                XCTFail("Unexpected error type: \(error)")
            }
        }
    }
    
    func testFetchVersionsForbidden() async throws {
        let text = "\nThe request failed with error response status: 403, error code: FORBIDDEN, error title: Access Denied, error detail: You do not have permission to access this resource."
        let expectedError = AppStoreConnectError.forbidden(errors: text)
        var mockClient = MockAPIClient()
        mockClient.result = .forbidden
        let client = AppStoreConnectClient(client: mockClient)
        let app = Application(id: "", bundleId: "")
        do {
            _ = try await client.fetchVersions(for: app)
            XCTFail("Expected error not thrown")
        } catch {
            if let appStoreConnectError = error as? AppStoreConnectError {
                XCTAssertEqual(appStoreConnectError, expectedError)
            } else {
                XCTFail("Unexpected error type: \(error)")
            }
        }
    }
    
    func testFetchVersionsNotFound() async throws {
        let text = "\nThe request failed with error response status: 404, error code: NOT_FOUND, error title: Resource Not Found, error detail: The requested resource was not found."
        let expectedError = AppStoreConnectError.notFound(errors: text)
        var mockClient = MockAPIClient()
        mockClient.result = .notFound
        let client = AppStoreConnectClient(client: mockClient)
        let app = Application(id: "", bundleId: "")
        do {
            _ = try await client.fetchVersions(for: app)
            XCTFail("Expected error not thrown")
        } catch {
            if let appStoreConnectError = error as? AppStoreConnectError {
                XCTAssertEqual(appStoreConnectError, expectedError)
            } else {
                XCTFail("Unexpected error type: \(error)")
            }
        }
    }
    
    func testFetchVersionsUnauthorized() async throws {
        let text = "\nThe request failed with error response status: 401, error code: UNAUTHORIZED, error title: Unauthorized, error detail: Authentication credentials were missing or incorrect."
        let expectedError = AppStoreConnectError.unauthorized(errors: text)
        var mockClient = MockAPIClient()
        mockClient.result = .unauthorized
        let client = AppStoreConnectClient(client: mockClient)
        let app = Application(id: "", bundleId: "")
        do {
            _ = try await client.fetchVersions(for: app)
            XCTFail("Expected error not thrown")
        } catch {
            if let appStoreConnectError = error as? AppStoreConnectError {
                XCTAssertEqual(appStoreConnectError, expectedError)
            } else {
                XCTFail("Unexpected error type: \(error)")
            }
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
