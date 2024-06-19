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
    let badRequest = 400
    let unauthorized = 401
    let forbidden = 403
    let notFound = 404
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
        let expectedError = "\nFailed with: \(badRequest), Foo, Bar, Baz."
        do {
            let result = try await client.fetchApps()
            XCTFail("Expected error not thrown, got result: \(result)")
        } catch AppStoreConnectError.badRequest(let error) {
            XCTAssertEqual(error, expectedError)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testFetchAppsForbidden() async throws {
        var mockClient = MockAPIClient()
        mockClient.result = .forbidden
        let client = AppStoreConnectClient(client: mockClient)
        let expectedError = "\nFailed with: \(forbidden), Foo, Bar, Baz."
        do {
            let result = try await client.fetchApps()
            XCTFail("Expected error not thrown, got result: \(result)")
        } catch AppStoreConnectError.forbidden(let error) {
            XCTAssertEqual(error, expectedError)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testFetchAppsUnauthorized() async throws {
        var mockClient = MockAPIClient()
        mockClient.result = .unauthorized
        let client = AppStoreConnectClient(client: mockClient)
        let expectedError = "\nFailed with: \(unauthorized), Foo, Bar, Baz."
        do {
            let result = try await client.fetchApps()
            XCTFail("Expected error not thrown, got result: \(result)")
        } catch AppStoreConnectError.unauthorized(let error) {
            XCTAssertEqual(error, expectedError)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testFetchAppsUndocumented() async throws {
        var mockClient = MockAPIClient()
        mockClient.result = .undocumented
        let client = AppStoreConnectClient(client: mockClient)
        let expectedError = 501
        do {
            let result = try await client.fetchApps()
            XCTFail("Expected error not thrown, got result: \(result)")
        } catch AppStoreConnectError.serverError(let error) {
            XCTAssertEqual(error, expectedError)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testFetchVersionsSuccess() async throws {
        var mockClient = MockAPIClient()
        mockClient.result = .ok
        let client = AppStoreConnectClient(client: mockClient)
        let app = Application(id: "", bundleId: "")
        let apps = try await client.fetchVersions(for: app)
        XCTAssertEqual(1, apps.count)
        XCTAssertEqual(apps.first?.appStoreState, MockObjects.appStoreVersion.attributes?.appStoreState?.rawValue)
        XCTAssertEqual(apps.first?.version, MockObjects.appStoreVersion.attributes?.versionString)
    }
    
    func testFetchVersionsBadRequest() async throws {
        var mockClient = MockAPIClient()
        mockClient.result = .badRequest
        let client = AppStoreConnectClient(client: mockClient)
        let app = Application(id: "", bundleId: "")
        let expectedError = "\nFailed with: \(badRequest), Foo, Bar, Baz."
        do {
            let result = try await client.fetchVersions(for: app)
            XCTFail("Expected error not thrown, got result: \(result)")
        } catch AppStoreConnectError.badRequest(let error) {
            XCTAssertEqual(error, expectedError)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testFetchVersionsForbidden() async throws {
        var mockClient = MockAPIClient()
        mockClient.result = .forbidden
        let client = AppStoreConnectClient(client: mockClient)
        let app = Application(id: "", bundleId: "")
        let expectedError = "\nFailed with: \(forbidden), Foo, Bar, Baz."
        do {
            let result = try await client.fetchVersions(for: app)
            XCTFail("Expected error not thrown, got result: \(result)")
        } catch AppStoreConnectError.forbidden(let error) {
            XCTAssertEqual(error, expectedError)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testFetchVersionsNotFound() async throws {
        var mockClient = MockAPIClient()
        mockClient.result = .notFound
        let client = AppStoreConnectClient(client: mockClient)
        let app = Application(id: "", bundleId: "")
        let expectedError = "\nFailed with: \(notFound), Foo, Bar, Baz."
        do {
            let result = try await client.fetchVersions(for: app)
            XCTFail("Expected error not thrown, got result: \(result)")
        } catch AppStoreConnectError.notFound(let error) {
            XCTAssertEqual(error, expectedError)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testFetchVersionsUnauthorized() async throws {
        var mockClient = MockAPIClient()
        mockClient.result = .unauthorized
        let client = AppStoreConnectClient(client: mockClient)
        let app = Application(id: "", bundleId: "")
        let expectedError = "\nFailed with: \(unauthorized), Foo, Bar, Baz."
        do {
            let result = try await client.fetchVersions(for: app)
            XCTFail("Expected error not thrown, got result: \(result)")
        } catch AppStoreConnectError.unauthorized(let error) {
            XCTAssertEqual(error, expectedError)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testFetchVersionsUndocumented() async throws {
        var mockClient = MockAPIClient()
        mockClient.result = .undocumented
        let client = AppStoreConnectClient(client: mockClient)
        let app = Application(id: "", bundleId: "")
        let expectedError = 501
        do {
            let result = try await client.fetchVersions(for: app)
            XCTFail("Expected error not thrown, got result: \(result)")
        } catch AppStoreConnectError.serverError(let error) {
            XCTAssertEqual(error, expectedError)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testFetchBuildsSuccess() async throws {
        var mockClient = MockAPIClient()
        mockClient.result = .ok
        let client = AppStoreConnectClient(client: mockClient)
        let app = Application(id: "Foo", bundleId: "Bar")
        let expectedBuilds = [Build(schema: MockObjects.build)]
        let build = try await client.fetchBuilds(
            for: app,
            with: BuildsQuery.init(
                sort: .hyphenVersion,
                fields: [.version, .minOsVersion, .uploadedDate]
            )
        )
        XCTAssertEqual(build, expectedBuilds)
    }
    
    func testFetchBuildsBadRequest() async throws {
        var mockClient = MockAPIClient()
        mockClient.result = .badRequest
        let client = AppStoreConnectClient(client: mockClient)
        let app = Application(id: "Foo", bundleId: "Bar")
        let expectedError = "\nFailed with: \(badRequest), Foo, Bar, Baz."
        do {
            let result = try await client.fetchBuilds(
                for: app,
                with: BuildsQuery.init(
                    sort: .hyphenVersion,
                    fields: [.version, .minOsVersion, .uploadedDate]
                )
            )
            XCTFail("Expected error not thrown, got result: \(String(describing: result))")
        } catch AppStoreConnectError.badRequest(let error) {
            XCTAssertEqual(error, expectedError)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testFetchBuildsUnauthorized() async throws {
        var mockClient = MockAPIClient()
        mockClient.result = .unauthorized
        let client = AppStoreConnectClient(client: mockClient)
        let app = Application(id: "Foo", bundleId: "Bar")
        let expectedError = "\nFailed with: \(unauthorized), Foo, Bar, Baz."
        do {
            let result = try await client.fetchBuilds(
                for: app,
                with: BuildsQuery.init(
                    sort: .hyphenVersion,
                    fields: [.version, .minOsVersion, .uploadedDate]
                )
            )
            XCTFail("Expected error not thrown, got result: \(String(describing: result))")
        } catch AppStoreConnectError.unauthorized(let error) {
            XCTAssertEqual(error, expectedError)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testFetchBuildsForbidden() async throws {
        var mockClient = MockAPIClient()
        mockClient.result = .forbidden
        let client = AppStoreConnectClient(client: mockClient)
        let app = Application(id: "Foo", bundleId: "Bar")
        let expectedError = "\nFailed with: \(forbidden), Foo, Bar, Baz."
        do {
            let result = try await client.fetchBuilds(
                for: app,
                with: BuildsQuery.init(
                    sort: .hyphenVersion,
                    fields: [.version, .minOsVersion, .uploadedDate]
                )
            )
            XCTFail("Expected error not thrown, got result: \(String(describing: result))")
        } catch AppStoreConnectError.forbidden(let error) {
            XCTAssertEqual(error, expectedError)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testFetchBuildsUndocumented() async throws {
        var mockClient = MockAPIClient()
        mockClient.result = .undocumented
        let client = AppStoreConnectClient(client: mockClient)
        let app = Application(id: "Foo", bundleId: "Bar")
        let expectedError = 501
        do {
            let result = try await client.fetchBuilds(
                for: app,
                with: BuildsQuery.init(
                    sort: .hyphenVersion,
                    fields: [.version, .minOsVersion, .uploadedDate]
                )
            )
            XCTFail("Expected error not thrown, got result: \(String(describing: result))")
        } catch AppStoreConnectError.serverError(let error) {
            XCTAssertEqual(error, expectedError)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testFetchPreReleaseVersionSuccess() async throws {
        var mockClient = MockAPIClient()
        mockClient.result = .ok
        let client = AppStoreConnectClient(client: mockClient)
        let build = Build(schema: MockObjects.build)
        let preReleaseVersion = try await client.fetchPreReleaseVersion(for: build)
        XCTAssertEqual(preReleaseVersion.id, "FooBarId")
        XCTAssertEqual(preReleaseVersion.version, "Foo")
        XCTAssertEqual(preReleaseVersion.platform, "IOS")
    }
    
    
    func testFetchPreReleaseVersionBadRequest() async throws {
        var mockClient = MockAPIClient()
        mockClient.result = .badRequest
        let client = AppStoreConnectClient(client: mockClient)
        let build = Build(schema: MockObjects.build)
        let expectedError = "\nFailed with: \(badRequest), Foo, Bar, Baz."
        do {
            let result = try await client.fetchPreReleaseVersion(for: build)
            XCTFail("Expected error not thrown, got result: \(result)")
        } catch AppStoreConnectError.badRequest(let error) {
            XCTAssertEqual(error, expectedError)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testFetchPreReleaseVersionUnauthorized() async throws {
        var mockClient = MockAPIClient()
        mockClient.result = .unauthorized
        let client = AppStoreConnectClient(client: mockClient)
        let build = Build(schema: MockObjects.build)
        let expectedError = "\nFailed with: \(unauthorized), Foo, Bar, Baz."
        do {
            let result = try await client.fetchPreReleaseVersion(for: build)
            XCTFail("Expected error not thrown, got result: \(result)")
        } catch AppStoreConnectError.unauthorized(let error) {
            XCTAssertEqual(error, expectedError)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testFetchPreReleaseVersionNotFound() async throws {
        var mockClient = MockAPIClient()
        mockClient.result = .notFound
        let client = AppStoreConnectClient(client: mockClient)
        let build = Build(schema: MockObjects.build)
        let expectedError = "\nFailed with: \(notFound), Foo, Bar, Baz."
        do {
            let result = try await client.fetchPreReleaseVersion(for: build)
            XCTFail("Expected error not thrown, got result: \(result)")
        } catch AppStoreConnectError.notFound(let error) {
            XCTAssertEqual(error, expectedError)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testFetchPreReleaseVersionForbidden() async throws {
        var mockClient = MockAPIClient()
        mockClient.result = .forbidden
        let client = AppStoreConnectClient(client: mockClient)
        let build = Build(schema: MockObjects.build)
        let expectedError = "\nFailed with: \(forbidden), Foo, Bar, Baz."
        do {
            let result = try await client.fetchPreReleaseVersion(for: build)
            XCTFail("Expected error not thrown, got result: \(result)")
        } catch AppStoreConnectError.forbidden(let error) {
            XCTAssertEqual(error, expectedError)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testFetchPreReleaseVersionUndocumented() async throws {
        var mockClient = MockAPIClient()
        mockClient.result = .undocumented
        let client = AppStoreConnectClient(client: mockClient)
        let build = Build(schema: MockObjects.build)
        let expectedError = 501
        do {
            let result = try await client.fetchPreReleaseVersion(for: build)
            XCTFail("Expected error not thrown, got result: \(result)")
        } catch AppStoreConnectError.serverError(let error) {
            XCTAssertEqual(error, expectedError)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testConvertSortPreReleaseVersion() {
        let query = BuildsQuery(sort: nil, fields: nil)
        let sort: [BuildsQuery.Sort] = [.preReleaseVersion]
        let result = query.convertSort(sort)
        XCTAssertEqual(result, .preReleaseVersion)
    }
    
    func testConvertSortHyphenPreReleaseVersion() {
        let query = BuildsQuery(sort: nil, fields: nil)
        let sort: [BuildsQuery.Sort] = [.hyphenPreReleaseVersion]
        let result = query.convertSort(sort)
        XCTAssertEqual(result, ._hyphen_preReleaseVersion)
    }
    
    func testConvertSortUploadedDate() {
        let query = BuildsQuery(sort: nil, fields: nil)
        let sort: [BuildsQuery.Sort] = [.uploadedDate]
        let result = query.convertSort(sort)
        XCTAssertEqual(result, .uploadedDate)
    }
    
    func testConvertSortHyphenUploadedDate() {
        let query = BuildsQuery(sort: nil, fields: nil)
        let sort: [BuildsQuery.Sort] = [.hyphenUploadedDate]
        let result = query.convertSort(sort)
        XCTAssertEqual(result, ._hyphen_uploadedDate)
    }
    
    func testConvertSortVersion() {
        let query = BuildsQuery(sort: nil, fields: nil)
        let sort: [BuildsQuery.Sort] = [.version]
        let result = query.convertSort(sort)
        XCTAssertEqual(result, .version)
    }
    
    func testConvertSortHyphenVersion() {
        let query = BuildsQuery(sort: nil, fields: nil)
        let sort: [BuildsQuery.Sort] = [.hyphenVersion]
        let result = query.convertSort(sort)
        XCTAssertEqual(result, ._hyphen_version)
    }
    
    func testConvertSortDefault() {
        let query = BuildsQuery(sort: nil, fields: nil)
        let sort: [BuildsQuery.Sort] = []
        let result = query.convertSort(sort)
        XCTAssertEqual(result, ._hyphen_version)
    }
}
