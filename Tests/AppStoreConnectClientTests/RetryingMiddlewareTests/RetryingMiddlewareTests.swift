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
    private let ok = 200
    private let notFound = 404
    private let tooManyRequests = 429
    private let internalServerError = 500
    private let logicError = 600
    
    func testSignalsInitialization() {
        let sut = RetryingMiddleware()
        XCTAssertTrue(sut.signals.contains(tooManyRequests))
        XCTAssertTrue(sut.signals.contains(internalServerError))
        XCTAssertFalse(sut.signals.contains(ok))
    }
    
    func testNotRepeatWithSetPolicyNever() async throws {
        let sut = RetryingMiddleware(
            signals: [.code(internalServerError)],
            policy: .never
        )
        let expectation = XCTestExpectation(
            description: "Expect 'next' to be called only once due to 'never' retry policy"
        )
        let next: @Sendable (
            HTTPRequest,
            HTTPBody?,
            URL
        ) async throws -> (HTTPResponse, HTTPBody?) = { _, _, _ in
            expectation.fulfill()
            let status = HTTPResponse.Status(code: self.internalServerError)
            return (HTTPResponse(status: status), nil)
        }
        let baseURL = try XCTUnwrap(URL(string: "http://example.com"), "Unwrap fail")
        let (response, _) = try await sut.intercept(
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
        await fulfillment(of: [expectation], timeout: 3.0)
        XCTAssertEqual(response.status.code, internalServerError)
    }
    
    func testNotRepeatWhenReturnTooManyRequests() async throws {
        let sut = RetryingMiddleware(
            signals: [.code(internalServerError)],
            policy: .upToAttempts(count: 3)
        )
        let expectation = XCTestExpectation(
            description: "Expect 'next' to be called only once due to receiving 'tooManyRequests' signal"
        )
        let next: @Sendable (
            HTTPRequest,
            HTTPBody?,
            URL
        ) async throws -> (HTTPResponse, HTTPBody?) = { _, _, _ in
            expectation.fulfill()
            let status = HTTPResponse.Status(code: self.tooManyRequests)
            return (HTTPResponse(status: status), nil)
        }
        let baseURL = try XCTUnwrap(URL(string: "http://example.com"), "Unwrap fail")
        let (response, _) = try await sut.intercept(
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
        await fulfillment(of: [expectation], timeout: 3.0)
        XCTAssertEqual(response.status.code, tooManyRequests)
    }
    
    func testNotRepeatWhenSetIterationBehaviorSingle() async throws {
        let sut = RetryingMiddleware(
            signals: [.code(internalServerError)],
            policy: .upToAttempts(count: 3)
        )
        let expectation = XCTestExpectation(
            description: "Expect 'next' to be called only once due to 'single' iteration behavior"
        )
        let next: @Sendable (
            HTTPRequest,
            HTTPBody?,
            URL
        ) async throws -> (HTTPResponse, HTTPBody?) = { _, _, _ in
            expectation.fulfill()
            let status = HTTPResponse.Status(code: self.internalServerError)
            return (HTTPResponse(status: status), nil)
        }
        let baseURL = try XCTUnwrap(URL(string: "http://example.com"), "Unwrap fail")
        let (response, _) = try await sut.intercept(
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
        await fulfillment(of: [expectation], timeout: 3.0)
        XCTAssertEqual(response.status.code, internalServerError)
    }
    
    func testRepeatsSetNumberOfAttempts() async throws {
        let sut = RetryingMiddleware(
            signals: [.code(internalServerError)],
            policy: .upToAttempts(count: 3)
        )
        let expectation = XCTestExpectation(
            description: "Expect 'next' to be called multiple times due to 'multiple' iteration behavior and retry policy"
        )
        expectation.expectedFulfillmentCount = 3
        let next: @Sendable (
            HTTPRequest,
            HTTPBody?,
            URL
        ) async throws -> (HTTPResponse, HTTPBody?) = { _, _, _ in
            expectation.fulfill()
            let status = HTTPResponse.Status(code: self.internalServerError)
            return (HTTPResponse(status: status), nil)
        }
        let baseURL = try XCTUnwrap(URL(string: "http://example.com"), "Unwrap fail")
        let (response, _) = try await sut.intercept(
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
        await fulfillment(of: [expectation], timeout: 3.0)
        XCTAssertEqual(response.status.code, internalServerError)
    }
    
    func testMaxAttemptsReachedError() async throws {
        let sut = RetryingMiddleware(
            signals: [.errorThrown],
            policy: .upToAttempts(count: 3)
        )
        var attemptCount = 0
        let baseURL = try XCTUnwrap(URL(string: "http://example.com"), "Unwrap fail")
        do {
            let result = try await sut.intercept(
                HTTPRequest(
                    method: .get,
                    scheme: "http",
                    authority: "example.com",
                    path: "/test"
                ),
                body: nil,
                baseURL: baseURL,
                operationID: "testOperation"
            ) { _, _, _ in
                attemptCount += 1
                throw RetryingError.maxAttemptsReached
            }
            XCTFail("Expected error not thrown, nevertheless got result: \(result)")
        } catch {
            XCTAssertEqual(attemptCount, 3)
            XCTAssertEqual(error as? RetryingError, .maxAttemptsReached)
        }
    }
}
