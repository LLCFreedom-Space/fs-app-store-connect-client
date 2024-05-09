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
        let statusCode = 400
        var mockClient = MockAPIClient()
        mockClient.result = .badRequest
        let client = AppStoreConnectClient(client: mockClient)
        let text = """
            \nThe request failed with: \(statusCode), BAD_REQUEST, Invalid Input, The provided data failed validation.
            """
        let expectedError = AppStoreConnectError.badRequest(errors: text)
        do {
            _ = try await client.fetchApps()
            XCTFail("Expected error not thrown")
        } catch {
            XCTAssertEqual(
                error as? AppStoreConnectError,
                expectedError,
                "Unexpected error: \(error)"
            )
        }
    }
    
    func testFetchAppsForbidden() async throws {
        let statusCode = 403
        var mockClient = MockAPIClient()
        mockClient.result = .forbidden
        let client = AppStoreConnectClient(client: mockClient)
        let text = """
            \nThe request failed with: \(statusCode), FORBIDDEN, Access Denied, You do not have permission to access this resource.
            """
        let expectedError = AppStoreConnectError.forbidden(errors: text)
        do {
            _ = try await client.fetchApps()
            XCTFail("Expected error not thrown")
        } catch {
            XCTAssertEqual(
                error as? AppStoreConnectError,
                expectedError,
                "Unexpected error: \(error)"
            )
        }
    }
    
    func testFetchAppsUnauthorized() async throws {
        let statusCode = 401
        var mockClient = MockAPIClient()
        mockClient.result = .unauthorized
        let client = AppStoreConnectClient(client: mockClient)
        let text = """
            \nThe request failed with: \(statusCode), UNAUTHORIZED, Unauthorized, Authentication credentials were missing or incorrect.
            """
        let expectedError = AppStoreConnectError.unauthorized(errors: text)
        do {
            _ = try await client.fetchApps()
            XCTFail("Expected error not thrown")
        } catch {
            XCTAssertEqual(
                error as? AppStoreConnectError,
                expectedError,
                "Unexpected error: \(error)"
            )
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
            XCTAssertEqual(
                AppStoreConnectError.serverError(errorCode: errorCode).localizedDescription,
                error.localizedDescription
            )
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
        let statusCode = 400
        let text = """
            \nThe request failed with: \(statusCode), BAD_REQUEST, Invalid Input, The provided data failed validation.
            """
        let expectedError = AppStoreConnectError.badRequest(errors: text)
        var mockClient = MockAPIClient()
        mockClient.result = .badRequest
        let client = AppStoreConnectClient(client: mockClient)
        let app = Application(id: "", bundleId: "")
        do {
            _ = try await client.fetchVersions(for: app)
            XCTFail("Expected error not thrown")
        } catch {
            XCTAssertEqual(
                error as? AppStoreConnectError,
                expectedError,
                "Unexpected error: \(error)"
            )
        }
    }
    
    func testFetchVersionsForbidden() async throws {
        let statusCode = 403
        let text = """
            \nThe request failed with: \(statusCode), FORBIDDEN, Access Denied, You do not have permission to access this resource.
            """
        let expectedError = AppStoreConnectError.forbidden(errors: text)
        var mockClient = MockAPIClient()
        mockClient.result = .forbidden
        let client = AppStoreConnectClient(client: mockClient)
        let app = Application(id: "", bundleId: "")
        do {
            _ = try await client.fetchVersions(for: app)
            XCTFail("Expected error not thrown")
        } catch {
            XCTAssertEqual(
                error as? AppStoreConnectError,
                expectedError,
                "Unexpected error: \(error)"
            )
        }
    }
    
    func testFetchVersionsNotFound() async throws {
        let statusCode = 404
        let text = """
            \nThe request failed with: \(statusCode), NOT_FOUND, Resource Not Found, The requested resource was not found.
            """
        let expectedError = AppStoreConnectError.notFound(errors: text)
        var mockClient = MockAPIClient()
        mockClient.result = .notFound
        let client = AppStoreConnectClient(client: mockClient)
        let app = Application(id: "", bundleId: "")
        do {
            _ = try await client.fetchVersions(for: app)
            XCTFail("Expected error not thrown")
        } catch {
            XCTAssertEqual(
                error as? AppStoreConnectError,
                expectedError,
                "Unexpected error: \(error)"
            )
        }
    }
    
    func testFetchVersionsUnauthorized() async throws {
        let statusCode = 401
        let text = """
            \nThe request failed with: \(statusCode), UNAUTHORIZED, Unauthorized, Authentication credentials were missing or incorrect.
            """
        let expectedError = AppStoreConnectError.unauthorized(errors: text)
        var mockClient = MockAPIClient()
        mockClient.result = .unauthorized
        let client = AppStoreConnectClient(client: mockClient)
        let app = Application(id: "", bundleId: "")
        do {
            _ = try await client.fetchVersions(for: app)
            XCTFail("Expected error not thrown")
        } catch {
            XCTAssertEqual(
                error as? AppStoreConnectError,
                expectedError,
                "Unexpected error: \(error)"
            )
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
            XCTAssertEqual(
                AppStoreConnectError.serverError(errorCode: errorCode).localizedDescription,
                error.localizedDescription
            )
        }
    }
}
