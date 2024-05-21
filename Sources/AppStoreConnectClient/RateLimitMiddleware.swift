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
package struct RateLimitMiddleware: ClientMiddleware {
    /// The key for the hourly request limit.
    private let hourLimit = "user-hour-lim"
    /// The key for the remaining request count.
    private let remaining = "user-hour-rem"
    /// The header for rate limit.
    private let rateLimitHeader = "x-rate-limit"
    
    /// Intercept and handle rate limit in the response.
    /// - Parameters:
    ///   - request: The HTTP request.
    ///   - body: The HTTP body.
    ///   - baseURL: The base URL.
    ///   - operationID: The operation ID.
    ///   - next: The next middleware.
    /// - Returns: A tuple containing the HTTP response and body.
    package func intercept(
        _ request: HTTPTypes.HTTPRequest,
        body: OpenAPIRuntime.HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (HTTPTypes.HTTPRequest, OpenAPIRuntime.HTTPBody?, URL) async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?)
    ) async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?) {
        let result = try await next(request, body, baseURL)
        guard let header = result.0.headerFields.first(where: { $0.name.rawName == rateLimitHeader }) else {
            throw RateLimitError.headerNotFound(expected: rateLimitHeader)
        }
        let dictionary = header.value.split(separator: ";").reduce(into: [String: Int]()) {
            let pair = $1.split(separator: ":")
            if let key = pair.first?.trimmingCharacters(in: .whitespaces),
               let value = pair.last?.trimmingCharacters(in: .whitespaces) {
                $0[String(key)] = Int(value)
            }
        }
        if let hourLimit = dictionary[hourLimit], let remaining = dictionary[remaining] {
            guard remaining > 0 else {
                throw RateLimitError.rateLimitExceeded(remaining: remaining, from: hourLimit)
            }
            return result
        } else {
            throw RateLimitError.invalidExpectedValues(
                "hourLimit: \(String(describing: dictionary[hourLimit])), remaining: \(String(describing: dictionary[remaining]))"
            )
        }
    }
}
