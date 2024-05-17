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

final class RetryingMiddlewareTests: XCTestCase {
    let sut = RetryingMiddleware()
    let tooManyRequests = 429
    let internalServerError = 500
    let logicError = 600
    let ok = 200
    
    func testRetryableSignalContainsCode() {
        let signals: Set<RetryingMiddleware.RetryableSignal> = [
            .code(tooManyRequests),
            .range(internalServerError..<logicError)
        ]
        XCTAssertTrue(sut.signals.contains(tooManyRequests))
        XCTAssertTrue(sut.signals.contains(internalServerError))
        XCTAssertFalse(sut.signals.contains(ok))
    }
    
    func testMiddlewareCheckPolicyStatusNever() async throws {
        let sut = RetryingMiddleware(policy: .never)
        let nextExpectation = expectation(description: "description: test")
        let next: @Sendable (
            HTTPRequest,
            HTTPBody?,
            URL
        ) async throws -> (HTTPResponse, HTTPBody?) = { _, _, _ in
            nextExpectation.fulfill()
            let status = HTTPResponse.Status(code: self.tooManyRequests)
            return (HTTPResponse(status: status), nil)
        }
        guard let baseURL = URL(string: "http://example.com") else {
            return
        }
        let (response, _) = try await sut.intercept(
            HTTPRequest(
                method: .get,
                scheme: "http",
                authority: "example.com",
                path: "/test"
            ),
            body: nil,
            baseURL: baseURL,
            operationID: "testOperation",
            next: next
        )
        await fulfillment(of: [nextExpectation])
        XCTAssertEqual(response.status.code, tooManyRequests)
    }
    
    func testMiddlewareRetryWhenResponseMatchesRetryStatusCodes() async throws {
        let middleware = RetryingMiddleware(
            signals: [.code(internalServerError)],
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
            let status = HTTPResponse.Status(code: self.internalServerError)
            return (HTTPResponse(status: status), nil)
        }
        guard let baseURL = URL(string: "http://example.com") else {
            return
        }
        let (response, _) = try await middleware.intercept(
            HTTPRequest(
                method: .get,
                scheme: "http",
                authority: "example.com",
                path: "/test"
            ),
            body: nil,
            baseURL: baseURL,
            operationID: "testOperation",
            next: next
        )
        await fulfillment(of: [nextExpectation])
        XCTAssertEqual(response.status.code, internalServerError)
    }
    
    func testCatchsErrorAndIsItAttemptToRestartTheRequest() async throws {
        let sut = RetryingMiddleware(
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
        guard let baseURL = URL(string: "http://example.com") else {
            return
        }
        do {
            try await sut.intercept(
                HTTPRequest(
                    method: .get,
                    scheme: "http",
                    authority: "example.com",
                    path: "/test"
                ),
                body: nil,
                baseURL: baseURL,
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
            signals: [.code(internalServerError)],
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
            let status = HTTPResponse.Status(code: self.internalServerError)
            return (HTTPResponse(status: status), nil)
        }
        guard let baseURL = URL(string: "http://example.com") else {
            return
        }
        let (response, _) = try await middleware.intercept(
            HTTPRequest(
                method: .get,
                scheme: "http",
                authority: "example.com",
                path: "/test"
            ),
            body: HTTPBody([1, 2, 3], length: .known(3), iterationBehavior: .single),
            baseURL: baseURL,
            operationID: "testOperation",
            next: next
        )
        await fulfillment(of: [nextExpectation])
        XCTAssertEqual(response.status.code, internalServerError)
    }
    
    func testMiddlewareRetryWhenBodyIterationBehaviorIsMultiple() async throws {
        let middleware = RetryingMiddleware(
            signals: [.code(internalServerError)],
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
            let status = HTTPResponse.Status(code: self.internalServerError)
            return (HTTPResponse(status: status), nil)
        }
        guard let baseURL = URL(string: "http://example.com") else {
            return
        }
        let (response, _) = try await middleware.intercept(
            HTTPRequest(
                method: .get,
                scheme: "http",
                authority: "example.com",
                path: "/test"
            ),
            body: HTTPBody([1, 2, 3], length: .known(3), iterationBehavior: .multiple),
            baseURL: baseURL,
            operationID: "testOperation",
            next: next
        )
        await fulfillment(of: [nextExpectation])
        XCTAssertEqual(response.status.code, internalServerError)
    }
    
    func testMiddlewareDelayBetweenRetries() async throws {
        let middleware = RetryingMiddleware(
            signals: [.code(internalServerError)],
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
            let status = HTTPResponse.Status(code: self.internalServerError)
            return (HTTPResponse(status: status), nil)
        }
        guard let baseURL = URL(string: "http://example.com") else {
            return
        }
        try await middleware.intercept(
            HTTPRequest(
                method: .get,
                scheme: "http",
                authority: "example.com",
                path: "/test"
            ),
            body: nil,
            baseURL: baseURL,
            operationID: "testOperation",
            next: next
        )
        await fulfillment(of: [nextExpectation])
        let elapsedTime = Date().timeIntervalSince(startTime)
        XCTAssertGreaterThanOrEqual(elapsedTime, 0.2, "Total delay should be at least 0.2 seconds")
    }
}
