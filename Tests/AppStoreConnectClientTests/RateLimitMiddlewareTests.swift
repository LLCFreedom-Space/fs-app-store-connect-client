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

class RateLimitMiddlewareTests: XCTestCase {
    func testExtractHeaderValueSuccess() throws {
        let sut = RateLimitMiddleware()
        var fields = HTTPFields()
        let unwrap = try XCTUnwrap(HTTPField.Name("x-rate-limit"))
        fields[unwrap] = "user-hour-lim:1111; user-hour-rem:222"
        let mockResponse = HTTPTypes.HTTPResponse(
            status: .accepted,
            headerFields: HTTPFields(fields[fields: unwrap])
        )
        XCTAssertNoThrow(try sut.extractHeaderValue(from: mockResponse, for: "x-rate-limit"))
    }
    
    func testExtractHeaderValueInvalidSearchingDataHeader() throws {
        let sut = RateLimitMiddleware()
        var fields = HTTPFields()
        let unwrap = try XCTUnwrap(HTTPField.Name("x-limit"))
        fields[unwrap] = "user-hour-lim:1111; user-hour-rem:222"
        let mockResponse = HTTPTypes.HTTPResponse(
            status: .accepted,
            headerFields: HTTPFields(fields[fields: unwrap])
        )
        do {
            _ = try sut.extractHeaderValue(from: mockResponse, for: "x-rate-limit")
            XCTFail("Expected error not thrown")
        } catch RateLimitError.invalidSearchingData(header: "x-rate-limit") {
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testExtractHeaderValueRateLimitExceeded() throws {
        let sut = RateLimitMiddleware()
        var fields = HTTPFields()
        let unwrap = try XCTUnwrap(HTTPField.Name("x-rate-limit"))
        fields[unwrap] = "user-hour-lim:1111; user-hour-rem: 0"
        let mockResponse = HTTPTypes.HTTPResponse(
            status: .accepted,
            headerFields: HTTPFields(fields[fields: unwrap])
        )
        do {
            _ = try sut.extractHeaderValue(from: mockResponse, for: "x-rate-limit")
            XCTFail("Expected error not thrown")
        } catch RateLimitError.rateLimitExceeded(remaining: 0, from: 1111) {
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testExtractHeaderInvalidExpectedValues() throws {
        let sut = RateLimitMiddleware()
        var fields = HTTPFields()
        let unwrap = try XCTUnwrap(HTTPField.Name("x-rate-limit"))
        fields[unwrap] = "user-hour-lim:1111 user-hour-rem: 222 user-hour-rem: 33"
        let mockResponse = HTTPTypes.HTTPResponse(
            status: .accepted,
            headerFields: HTTPFields(fields[fields: unwrap])
        )
        do {
            _ = try sut.extractHeaderValue(from: mockResponse, for: "x-rate-limit")
            XCTFail("Expected error not thrown")
        } catch RateLimitError.invalidExpectedValues {
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
