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
//  RateLimitMiddlewareTests 2.swift
//
//
//  Created by Mykola Vasyk on 15.05.2024.
//

import XCTest
import HTTPTypes
import OpenAPIRuntime
@testable import AppStoreConnectClient

final class RateLimitMiddlewareTests: XCTestCase {
    func testInterceptSuccess() async throws {
        let request = HTTPTypes.HTTPRequest(
            method: .get,
            scheme: "http",
            authority: "example.com",
            path: "/test"
        )
        var fields = HTTPFields()
        let unwrap = try XCTUnwrap(HTTPField.Name("x-rate-limit"))
        fields[unwrap] = "user-hour-lim:1111; user-hour-rem:222"
        guard let baseURL = URL(string: "http://example.com") else {
            return
        }
        let httpResponse = HTTPTypes.HTTPResponse(
            status: .accepted,
            headerFields: HTTPFields(fields[fields: unwrap])
        )
        let sut = RateLimitMiddleware()
        do {
            let interceptedResponse = try await sut.intercept(
                request,
                body: nil,
                baseURL: baseURL,
                operationID: "someOperationID"
            ) { _, _, _ in
                return (httpResponse, nil)
            }
            XCTAssertEqual(interceptedResponse.0.status, .accepted)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testInterceptFailure() async throws {
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
        guard let baseURL = URL(string: "http://example.com") else {
            return
        }
        let httpResponse = HTTPTypes.HTTPResponse(
            status: .accepted,
            headerFields: HTTPFields(fields[fields: unwrap])
        )
        let sut = RateLimitMiddleware()
        do {
            try await sut.intercept(
                request,
                body: nil,
                baseURL: baseURL,
                operationID: "someOperationID"
            ) { _, _, _ in
                return (httpResponse, nil)
            }
            XCTFail("Expected rate limit exceeded error")
        } catch RateLimitError.rateLimitExceeded(let remaining, let from) {
            XCTAssertEqual(remaining, 0)
            XCTAssertEqual(from, limit)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testHeaderValidationFailed() async throws {
        let request = HTTPTypes.HTTPRequest(
            method: .get,
            scheme: "http",
            authority: "example.com",
            path: "/test"
        )
        var fields = HTTPFields()
        let unwrap = try XCTUnwrap(HTTPField.Name("x"))
        fields[unwrap] = "user-hour-lim:1111; user-hour-rem:222"
        guard let baseURL = URL(string: "http://example.com") else {
            return
        }
        let httpResponse = HTTPTypes.HTTPResponse(
            status: .accepted,
            headerFields: HTTPFields(fields[fields: unwrap])
        )
        let sut = RateLimitMiddleware()
        do {
            try await sut.intercept(
                request,
                body: nil,
                baseURL: baseURL,
                operationID: "someOperationID"
            ) { _, _, _ in
                return (httpResponse, nil)
            }
            XCTFail("Expected error not thrown")
        } catch RateLimitError.headerValidationFailed(header: "x-rate-limit") {
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testRateLimitExceeded() async throws {
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
        guard let baseURL = URL(string: "http://example.com") else {
            return
        }
        let httpResponse = HTTPTypes.HTTPResponse(
            status: .accepted,
            headerFields: HTTPFields(fields[fields: unwrap])
        )
        let sut = RateLimitMiddleware()
        do {
            try await sut.intercept(
                request,
                body: nil,
                baseURL: baseURL,
                operationID: "someOperationID"
            ) { _, _, _ in
                return (httpResponse, nil)
            }
            XCTFail("Expected error not thrown")
        } catch RateLimitError.rateLimitExceeded(remaining: 0, from: limit) {
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testExtractHeaderInvalidExpectedValues() async throws {
        let request = HTTPTypes.HTTPRequest(
            method: .get,
            scheme: "http",
            authority: "example.com",
            path: "/test"
        )
        var fields = HTTPFields()
        let unwrap = try XCTUnwrap(HTTPField.Name("x-rate-limit"))
        fields[unwrap] = "user-hour-lim: user-hour-rem: user-hour-rem:"
        guard let baseURL = URL(string: "http://example.com") else {
            return
        }
        let httpResponse = HTTPTypes.HTTPResponse(
            status: .accepted,
            headerFields: HTTPFields(fields[fields: unwrap])
        )
        let sut = RateLimitMiddleware()
        do {
            try await sut.intercept(
                request,
                body: nil,
                baseURL: baseURL,
                operationID: "someOperationID"
            ) { _, _, _ in
                return (httpResponse, nil)
            }
            XCTFail("Expected error not thrown")
        } catch RateLimitError.invalidExpectedValues {
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
