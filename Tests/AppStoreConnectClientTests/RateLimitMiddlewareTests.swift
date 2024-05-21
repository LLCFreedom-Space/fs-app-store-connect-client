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
//  RateLimitMiddlewareTests.swift
//
//
//  Created by Mykola Vasyk on 15.05.2024.
//

import XCTest
import HTTPTypes
import OpenAPIRuntime
@testable import AppStoreConnectClient

final class RateLimitMiddlewareTests: XCTestCase {
    func testRateLimitAllowsRequests() async throws {
        let request = HTTPTypes.HTTPRequest(
            method: .get,
            scheme: "http",
            authority: "example.com",
            path: "/test"
        )
        var fields = HTTPFields()
        let unwrap = try XCTUnwrap(HTTPField.Name("x-rate-limit"))
        fields[unwrap] = "user-hour-lim:1111; user-hour-rem:222"
        let baseURL = try XCTUnwrap(URL(string: "http://example.com"), "Unwrap fail")
        let httpResponse = HTTPTypes.HTTPResponse(
            status: .accepted,
            headerFields: HTTPFields(fields[fields: unwrap])
        )
        let sut = RateLimitMiddleware()
        do {
            let result = try await sut.intercept(
                request,
                body: nil,
                baseURL: baseURL,
                operationID: "someOperationID"
            ) { _, _, _ in
                return (httpResponse, nil)
            }
            XCTAssertEqual(result.0.status, .accepted)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testThrowRateLimitExceeded() async throws {
        let limit = 1111
        let request = HTTPTypes.HTTPRequest(
            method: .get,
            scheme: "http",
            authority: "example.com",
            path: "/test"
        )
        var fields = HTTPFields()
        let unwrap = try XCTUnwrap(HTTPField.Name("x-rate-limit"))
        fields[unwrap] = "user-hour-lim:1111; user-hour-rem:0"
        let baseURL = try XCTUnwrap(URL(string: "http://example.com"), "Unwrap fail")
        let httpResponse = HTTPTypes.HTTPResponse(
            status: .accepted,
            headerFields: HTTPFields(fields[fields: unwrap])
        )
        let sut = RateLimitMiddleware()
        do {
            let result = try await sut.intercept(
                request,
                body: nil,
                baseURL: baseURL,
                operationID: "someOperationID"
            ) { _, _, _ in
                return (httpResponse, nil)
            }
            XCTFail("Expected error not thrown, nevertheless got result: \(result)")
        } catch RateLimitError.rateLimitExceeded(let remaining, let from) {
            XCTAssertEqual(remaining, 0)
            XCTAssertEqual(from, limit)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testHeaderValidationFailed() async throws {
        let incorrectHeader = "x"
        let correctHeader = "x-rate-limit"
        let unwrapCorrectHeader = try XCTUnwrap(HTTPField.Name("x-rate-limit"))
        var fields = HTTPFields()
        let unwrapIncorrectHeader = try XCTUnwrap(HTTPField.Name(incorrectHeader))
        fields[unwrapIncorrectHeader] = "user-hour-lim:1111; user-hour-rem:222"
        let baseURL = try XCTUnwrap(URL(string: "http://example.com"), "Unwrap fail")
        let request = HTTPTypes.HTTPRequest(
            method: .get,
            scheme: "http",
            authority: "example.com",
            path: "/test"
        )
        let httpResponse = HTTPTypes.HTTPResponse(
            status: .accepted,
            headerFields: HTTPFields(fields[fields: unwrapIncorrectHeader])
        )
        let sut = RateLimitMiddleware()
        do {
            let result = try await sut.intercept(
                request,
                body: nil,
                baseURL: baseURL,
                operationID: "someOperationID"
            ) { _, _, _ in
                return (httpResponse, nil)
            }
            XCTFail("Expected error not thrown, nevertheless got result: \(result)")
        } catch RateLimitError.headerNotFound(expected: correctHeader) {
            XCTAssertNotEqual(unwrapIncorrectHeader, unwrapCorrectHeader)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testHandlingInvalidExpectedValues() async throws {
        let request = HTTPTypes.HTTPRequest(
            method: .get,
            scheme: "http",
            authority: "example.com",
            path: "/test"
        )
        var fields = HTTPFields()
        let unwrap = try XCTUnwrap(HTTPField.Name("x-rate-limit"))
        fields[unwrap] = "user-hour-lim: user-hour-rem: user-hour-rem:"
        let baseURL = try XCTUnwrap(URL(string: "http://example.com"), "Unwrap fail")
        let httpResponse = HTTPTypes.HTTPResponse(
            status: .accepted,
            headerFields: HTTPFields(fields[fields: unwrap])
        )
        let sut = RateLimitMiddleware()
        do {
            let result = try await sut.intercept(
                request,
                body: nil,
                baseURL: baseURL,
                operationID: "someOperationID"
            ) { _, _, _ in
                return (httpResponse, nil)
            }
            XCTFail("Expected error not thrown, nevertheless got result: \(result)")
        } catch RateLimitError.invalidExpectedValues {
            XCTAssert(true, "RateLimitError.invalidExpectedValues was thrown as expected")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
