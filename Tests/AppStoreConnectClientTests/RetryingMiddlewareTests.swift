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
//  RetryingMiddlewareTests.swift
//
//
//  Created by Mykola Vasyk on 16.05.2024.
//

import XCTest
import HTTPTypes
import OpenAPIRuntime
@testable import AppStoreConnectClient

class RetryingMiddlewareTests: XCTestCase {
    let sut = RetryingMiddleware()
    let error429 = 429
    let error500 = 500
    let ok200 = 200
    func testRetryableSignalContainsCode() {
        let signals: Set<RetryingMiddleware.RetryableSignal> = [
            .code(RetryingMiddleware.error429),
            .range(RetryingMiddleware.error500..<RetryingMiddleware.error600)
        ]
        XCTAssertTrue(signals.contains(error429))
        XCTAssertTrue(signals.contains(error500))
        XCTAssertFalse(signals.contains(ok200))
    }
    
    func testMiddlewareShouldNotRetryWhenPolicyIsNever() async throws {
        let sut = RetryingMiddleware(policy: .never)
        let nextExpectation = expectation(description: "description: test")
        let next: @Sendable (
            HTTPRequest,
            HTTPBody?,
            URL
        ) async throws -> (HTTPResponse, HTTPBody?) = { _, _, _ in
            nextExpectation.fulfill()
            let status = HTTPResponse.Status(code: self.error500)
            return (HTTPResponse(status: status), nil)
        }
        let (response, _) = try await sut.intercept(
            HTTPRequest(
                method: .get,
                scheme: "http",
                authority: "example.com",
                path: "/test"
            ),
            body: nil,
            baseURL: URL(string: "http://example.com")!,
            operationID: "testOperation",
            next: next
        )
        await fulfillment(of: [nextExpectation])
        XCTAssertEqual(response.status.code, error500)
    }
    
    func testMiddlewareRetryWhenResponseMatchesRetryStatusCodes() async throws {
        let middleware = RetryingMiddleware(
            signals: [.code(error500)],
            policy: .upToAttempts(count: 3),
            delay: .none
        )
        let nextExpectation = expectation(description: "description: test")
        nextExpectation.expectedFulfillmentCount = 3
        let next: @Sendable (
            HTTPRequest,
            HTTPBody?,
            URL
        ) async throws -> (HTTPResponse, HTTPBody?) = { _, _, _ in
            nextExpectation.fulfill()
            let status = HTTPResponse.Status(code: self.error500)
            return (HTTPResponse(status: status), nil)
        }
        let (response, _) = try await middleware.intercept(
            HTTPRequest(
                method: .get,
                scheme: "http",
                authority: "example.com",
                path: "/test"
            ),
            body: nil,
            baseURL: URL(string: "http://example.com")!,
            operationID: "testOperation",
            next: next
        )
        await fulfillment(of: [nextExpectation])
        XCTAssertEqual(response.status.code, error500)
    }
    
    func testMiddlewareRetryWhenErrorIsThrown() async throws {
        let middleware = RetryingMiddleware(
            signals: [.errorThrown],
            policy: .upToAttempts(count: 3),
            delay: .none
        )
        let nextExpectation = expectation(description: "description: test")
        nextExpectation.expectedFulfillmentCount = 3
        let next: @Sendable (
            HTTPRequest,
            HTTPBody?,
            URL
        ) async throws -> (HTTPResponse, HTTPBody?) = { _, _, _ in
            nextExpectation.fulfill()
            throw NSError(domain: "testError", code: 1, userInfo: nil)
        }
        do {
            _ = try await middleware.intercept(
                HTTPRequest(
                    method: .get,
                    scheme: "http",
                    authority: "example.com",
                    path: "/test"
                ),
                body: nil,
                baseURL: URL(string: "http://example.com")!,
                operationID: "testOperation",
                next: next
            )
            XCTFail("Expected error not thrown")
        } catch {
            XCTAssertEqual((error as NSError).domain, "testError")
        }
        await fulfillment(of: [nextExpectation])
    }
    
    func testMiddlewareNotRetryWhenBodyIterationBehaviorIsNotMultiple() async throws {
        let middleware = RetryingMiddleware(
            signals: [.code(error500)],
            policy: .upToAttempts(count: 3),
            delay: .none
        )
        let nextExpectation = expectation(description: "description: test")
        let next: @Sendable (
            HTTPRequest,
            HTTPBody?,
            URL
        ) async throws -> (HTTPResponse, HTTPBody?) = { _, _, _ in
            nextExpectation.fulfill()
            let status = HTTPResponse.Status(code: self.error500)
            return (HTTPResponse(status: status), nil)
        }
        let (response, _) = try await middleware.intercept(
            HTTPRequest(
                method: .get,
                scheme: "http",
                authority: "example.com",
                path: "/test"
            ),
            body: HTTPBody([1, 2, 3], length: .known(3), iterationBehavior: .single),
            baseURL: URL(string: "http://example.com")!,
            operationID: "testOperation",
            next: next
        )
        await fulfillment(of: [nextExpectation])
        XCTAssertEqual(response.status.code, error500)
    }
    
    func testMiddlewareRetryWhenBodyIterationBehaviorIsMultiple() async throws {
        let middleware = RetryingMiddleware(
            signals: [.code(error500)],
            policy: .upToAttempts(count: 3),
            delay: .none
        )
        let nextExpectation = expectation(description: "description: test")
        nextExpectation.expectedFulfillmentCount = 3
        let next: @Sendable (
            HTTPRequest,
            HTTPBody?,
            URL
        ) async throws -> (HTTPResponse, HTTPBody?) = { _, _, _ in
            nextExpectation.fulfill()
            let status = HTTPResponse.Status(code: self.error500)
            return (HTTPResponse(status: status), nil)
        }
        let (response, _) = try await middleware.intercept(
            HTTPRequest(
                method: .get,
                scheme: "http",
                authority: "example.com",
                path: "/test"
            ),
            body: HTTPBody([1, 2, 3], length: .known(3), iterationBehavior: .multiple),
            baseURL: URL(string: "http://example.com")!,
            operationID: "testOperation",
            next: next
        )
        await fulfillment(of: [nextExpectation])
        XCTAssertEqual(response.status.code, error500)
    }
    
    func testMiddlewareDelayBetweenRetries() async throws {
        let middleware = RetryingMiddleware(
            signals: [.code(error500)],
            policy: .upToAttempts(count: 3),
            delay: .constant(seconds: 0.1)
        )
        let nextExpectation = expectation(description: "description: test")
        nextExpectation.expectedFulfillmentCount = 3
        let startTime = Date()
        let next: @Sendable (
            HTTPRequest,
            HTTPBody?,
            URL
        ) async throws -> (HTTPResponse, HTTPBody?) = { _, _, _ in
            nextExpectation.fulfill()
            let status = HTTPResponse.Status(code: self.error500)
            return (HTTPResponse(status: status), nil)
        }
        _ = try await middleware.intercept(
            HTTPRequest(
                method: .get,
                scheme: "http",
                authority: "example.com",
                path: "/test"
            ),
            body: nil,
            baseURL: URL(string: "http://example.com")!,
            operationID: "testOperation",
            next: next
        )
        await fulfillment(of: [nextExpectation])
        let elapsedTime = Date().timeIntervalSince(startTime)
        XCTAssertGreaterThanOrEqual(elapsedTime, 0.2, "Total delay should be at least 0.2 seconds")
    }
}
