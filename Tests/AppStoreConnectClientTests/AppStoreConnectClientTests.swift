import XCTest
@testable import AppStoreConnectClient

final class AppStoreConnectClientTests: XCTestCase {
    func testFetchAppsSuccess() async throws {
        var mockClient = MockClient()
        mockClient.result = "ok"
        let client = AppStoreConnectClient(client: mockClient)
        let apps = try await client.fetchApps()
        XCTAssertEqual(1, apps.count)
        XCTAssertEqual("1234567", apps.first?.id)
        XCTAssertEqual("com.example.app", apps.first?.bundleID)
    }
    
    func testFetchAppsBadRequest() async throws {
        var mockClient = MockClient()
        mockClient.result = "badRequest"
        let client = AppStoreConnectClient(client: mockClient)
        
        do {
            _ = try await client.fetchApps()
            XCTFail("Expected error not thrown")
        } catch {
            XCTAssertEqual(AppStoreConnectError.badRequest.localizedDescription, error.localizedDescription)
        }
    }
    
    func testFetchAppsForbidden() async throws {
        var mockClient = MockClient()
        mockClient.result = "forbidden"
        let client = AppStoreConnectClient(client: mockClient)
        
        do {
            _ = try await client.fetchApps()
            XCTFail("Expected error not thrown")
        } catch {
            XCTAssertEqual(AppStoreConnectError.forbidden.localizedDescription, error.localizedDescription)
        }
    }
    
    func testFetchAppsUnauthorized() async throws {
        var mockClient = MockClient()
        mockClient.result = "unauthorized"
        let client = AppStoreConnectClient(client: mockClient)
        
        do {
            _ = try await client.fetchApps()
            XCTFail("Expected error not thrown")
        } catch {
            XCTAssertEqual(AppStoreConnectError.unauthorized.localizedDescription, error.localizedDescription)
        }
    }
    
    func testFetchAppsUndocumented() async throws {
        var mockClient = MockClient()
        mockClient.result = "undocumented"
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
        var mockClient = MockClient()
        mockClient.result = "ok"
        let client = AppStoreConnectClient(client: mockClient)
        let app = Application(id: "", bundleID: "")
        let apps = try await client.fetchVersions(for: app)
        XCTAssertEqual(1, apps.count)
        XCTAssertEqual(apps.first?.appStoreState, "ACCEPTED")
        XCTAssertEqual(apps.first?.version, "1.1.1")
    }
    
    func testFetchVersionsBadRequest() async throws {
        var mockClient = MockClient()
        mockClient.result = "badRequest"
        let client = AppStoreConnectClient(client: mockClient)
        let app = Application(id: "", bundleID: "")
        do {
            _ = try await client.fetchVersions(for: app)
            XCTFail("Expected error not thrown")
        } catch {
            XCTAssertEqual(AppStoreConnectError.badRequest.localizedDescription, error.localizedDescription)
        }
    }
    
    func testFetchVersionsForbidden() async throws {
        var mockClient = MockClient()
        mockClient.result = "forbidden"
        let client = AppStoreConnectClient(client: mockClient)
        let app = Application(id: "", bundleID: "")
        do {
            _ = try await client.fetchVersions(for: app)
            XCTFail("Expected error not thrown")
        } catch {
            XCTAssertEqual(AppStoreConnectError.forbidden.localizedDescription, error.localizedDescription)
        }
    }
    
    func testFetchVersionsNotFound() async throws {
        var mockClient = MockClient()
        mockClient.result = "notFound"
        let client = AppStoreConnectClient(client: mockClient)
        let app = Application(id: "", bundleID: "")
        do {
            _ = try await client.fetchVersions(for: app)
            XCTFail("Expected error not thrown")
        } catch {
            XCTAssertEqual(AppStoreConnectError.notFound.localizedDescription, error.localizedDescription)
        }
    }
    
    func testFetchVersionsUnauthorized() async throws {
        var mockClient = MockClient()
        mockClient.result = "unauthorized"
        let client = AppStoreConnectClient(client: mockClient)
        let app = Application(id: "", bundleID: "")
        do {
            _ = try await client.fetchVersions(for: app)
            XCTFail("Expected error not thrown")
        } catch {
            XCTAssertEqual(AppStoreConnectError.unauthorized.localizedDescription, error.localizedDescription)
        }
    }
    
    func testFetchVersionsUndocumented() async throws {
        var mockClient = MockClient()
        mockClient.result = "undocumented"
        let client = AppStoreConnectClient(client: mockClient)
        let app = Application(id: "", bundleID: "")
        do {
            _ = try await client.fetchVersions(for: app)
            XCTFail("Expected error not thrown")
        } catch {
            let errorCode = 501
            XCTAssertEqual(AppStoreConnectError.serverError(errorCode: errorCode).localizedDescription, error.localizedDescription)
        }
    }
}
