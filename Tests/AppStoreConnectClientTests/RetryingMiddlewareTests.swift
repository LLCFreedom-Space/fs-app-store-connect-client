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
    let ok = 200
    let notFound = 404
    let tooManyRequests = 429
    let internalServerError = 500
    let logicError = 600
    
    func testRetryableSignalContainsCode() {
        let sut = RetryingMiddleware()
        XCTAssertTrue(sut.signals.contains(tooManyRequests))
        XCTAssertTrue(sut.signals.contains(internalServerError))
        XCTAssertFalse(sut.signals.contains(ok))
    }
    
    func testRetryingMiddlewareSucceed() async throws {
        let sut = RetryingMiddleware(
            signals: [.code(ok)],
            policy: .upToAttempts(count: 3)
        )
        var fields = HTTPFields()
        let unwrap = try XCTUnwrap(HTTPField.Name("x-rate-limit"))
        fields[unwrap] = "user-hour-lim:1111; user-hour-rem:222"
        let httpResponse = HTTPTypes.HTTPResponse(
            status: HTTPResponse.Status(code: self.ok),
            headerFields: HTTPFields(fields[fields: unwrap])
        )
        let next: @Sendable (
            HTTPRequest,
            HTTPBody?,
            URL
        ) async throws -> (HTTPResponse, HTTPBody?) = { _, _, _ in
            return (httpResponse, nil)
        }
        let baseURL = try XCTUnwrap(URL(string: "http://example.com"), "Unwrap fail")
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
        let rateLimitHeaderExists = response.headerFields.first { $0.name.rawName == "x-rate-limit" } != nil
        XCTAssertEqual(response.status.code, ok)
        XCTAssertTrue(rateLimitHeaderExists, "Header 'x-rate-limit' should exist")
    }
    
    func testNotRepeatWithPolicyNever() async throws {
        let sut = RetryingMiddleware(
            signals: [.code(internalServerError)],
            policy: .never
        )
        let expectation = XCTestExpectation(
            description: "Expect 'next' to be called only once due to 'never' retry policy"
        )
        expectation.expectedFulfillmentCount = 1
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
        XCTAssertEqual(response.status.code, internalServerError)
        await fulfillment(of: [expectation], timeout: 3.0)
    }
    
    func testNotRepeatAfterSignalCodeTooManyRequests() async throws {
        let sut = RetryingMiddleware(
            signals: [.code(internalServerError)],
            policy: .upToAttempts(count: 3)
        )
        let expectation = XCTestExpectation(
            description: "Expect 'next' to be called only once due to receiving 'tooManyRequests' signal"
        )
        expectation.expectedFulfillmentCount = 1
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
        XCTAssertEqual(response.status.code, tooManyRequests)
        await fulfillment(of: [expectation], timeout: 3.0)
    }
    
    func testNotRepeatWhenBodyIterationBehaviorSingle() async throws {
        let sut = RetryingMiddleware(
            signals: [.code(internalServerError)],
            policy: .upToAttempts(count: 3)
        )
        let expectation = XCTestExpectation(
            description: "Expect 'next' to be called only once due to 'single' iteration behavior"
        )
        expectation.expectedFulfillmentCount = 1
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
        XCTAssertEqual(response.status.code, internalServerError)
        await fulfillment(of: [expectation], timeout: 3.0)
    }
    
    func testRepeatWhenIterationBehaviorMultipleAndPolicyRepeat() async throws {
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
        XCTAssertEqual(response.status.code, internalServerError)
        await fulfillment(of: [expectation], timeout: 3.0)
    }
    
    func testIfSignalsContainsError() async throws {
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
                throw URLError(URLError.Code(rawValue: notFound))
            }
            XCTAssertNil(result)
        } catch {
            XCTAssertEqual(attemptCount, 3)
            return
        }
        XCTFail("The middleware should throw an error after all retry attempts.")
    }
}
