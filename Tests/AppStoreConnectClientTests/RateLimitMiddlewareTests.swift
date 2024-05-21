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
    
    func testRateLimitExceededError() async throws {
        let expectedLimit = 1111
        let expectedRemaining = 0
        let request = HTTPTypes.HTTPRequest(
            method: .get,
            scheme: "http",
            authority: "example.com",
            path: "/test"
        )
        var fields = HTTPFields()
        let unwrap = try XCTUnwrap(HTTPField.Name("x-rate-limit"))
        fields[unwrap] = "user-hour-lim:\(expectedLimit); user-hour-rem:\(expectedRemaining)"
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
        } catch RateLimitError.rateLimitExceeded(let remaining, let limit) {
            XCTAssertEqual(remaining, expectedRemaining)
            XCTAssertEqual(limit, expectedLimit)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testHeaderNotFoundError() async throws {
        let correctHeader = "x-rate-limit"
        var fields = HTTPFields()
        let unwrapIncorrectHeader = try XCTUnwrap(HTTPField.Name("x"))
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
        } catch {
            XCTAssertEqual(error as? RateLimitError, .headerNotFound(expected: correctHeader))
        }
    }
    
    func testUnexpectedValuesError() async throws {
        var result: (HTTPResponse, HTTPBody?)?
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
            result = try await sut.intercept(
                request,
                body: nil,
                baseURL: baseURL,
                operationID: "someOperationID"
            ) { _, _, _ in
                return (httpResponse, nil)
            }
            XCTFail("Expected error not thrown, nevertheless got result: \(String(describing: result))")
        } catch {
            XCTAssertEqual(
                error as? RateLimitError,
                .unexpectedValues(
                    "hourLimit: \(String(describing: result?.0)), remaining: \(String(describing: result?.0))"
                )
            )
        }
    }
}
