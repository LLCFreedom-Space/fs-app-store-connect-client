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
//  RateLimitMiddleware.swift
//
//
//  Created by Mykola Vasyk on 10.05.2024.
//

import OpenAPIRuntime
import Foundation
import HTTPTypes

/// Middleware for handling rate limits from App Store Connect.
public struct RateLimitMiddleware: ClientMiddleware {
    /// The key for the hourly request limit.
    private let hourLimit = "user-hour-lim"
    /// The key for the remaining request count.
    private let remaining = "user-hour-rem"
    /// The header for rate limit.
    private let header = "x-rate-limit"
    
    /// Intercept and handle rate limit in the response.
    /// - Parameters:
    ///   - request: The HTTP request.
    ///   - body: The HTTP body.
    ///   - baseURL: The base URL.
    ///   - operationID: The operation ID.
    ///   - next: The next middleware.
    /// - Returns: A tuple containing the HTTP response and body.
    public func intercept(
        _ request: HTTPTypes.HTTPRequest,
        body: OpenAPIRuntime.HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (HTTPTypes.HTTPRequest, OpenAPIRuntime.HTTPBody?, URL) async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?)
    ) async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?) {
        let result = try await next(request, body, baseURL)
        let data = result.0
        _ = try extractHeaderValue(from: data, for: header)
        return result
    }
    
    /// Extracts the value of the specified header key from the HTTP response.
    /// - Parameters:
    ///   - response: The HTTP response.
    ///   - header: The header for search.
    /// - Throws: An errors if the header, the keys is not found or if the values cannot be extracted.
    func extractHeaderValue(
        from response: HTTPTypes.HTTPResponse,
        for header: String
    ) throws {
        guard let serverHeader = response.headerFields.first(where: {
            return $0.name.rawName == header
        }) else {
            throw RateLimitError.invalidSearchingData(header: header)
        }
        let dictionary = serverHeader.value.split(separator: ";").reduce(into: [String: Int]()) {
            let pair = $1.split(separator: ":")
            if let key = pair.first?.trimmingCharacters(in: .whitespaces),
               let value = pair.last?.trimmingCharacters(in: .whitespaces) {
                $0[String(key)] = Int(value)
            }
        }
        if let valueLimit = dictionary[hourLimit], let value = dictionary[remaining] {
            guard value > 0 else {
                throw RateLimitError.rateLimitExceeded(remaining: value, from: valueLimit)
            }
        } else {
            throw RateLimitError.invalidExpectedValues
        }
    }
}

/// Possible errors thrown by `RateLimitMiddleware`.
public enum RateLimitError: Error, Equatable {
    /// The specified search header was not found.
    case invalidSearchingData(header: String?)
    /// The client has exceeded the rate limit for the values.
    case rateLimitExceeded(remaining: Int, from: Int)
    /// Unable to extract values of rate limit.
    case invalidExpectedValues
}
