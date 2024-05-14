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
    /// The key for the hourly request limit header.
    public let hourLimit = "user-hour-lim"
    /// The key for the remaining request count header.
    public let remaining = "user-hour-rem"
    
    /// Intercept and handle rate limit headers in the response.
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
        let hourLimit = try extractHeaderValue(from: data, forKey: hourLimit)
        let remaining = try extractHeaderValue(from: data, forKey: remaining)
        debugPrint("\nServer request limit per hour: \(hourLimit), remaining: \(remaining)")
        return result
    }
    
    /// Extracts the value of the specified header key from the HTTP response.
    /// - Parameters:
    ///   - response: The HTTP response.
    ///   - key: The header key to extract.
    /// - Returns: The value of the header key.
    /// - Throws: An error if the key is not found or if the value cannot be extracted.
    private func extractHeaderValue(
        from response: HTTPTypes.HTTPResponse,
        forKey key: String
    ) throws -> Int {
        let items = String(describing: response.headerFields)
            .split(separator: ",", omittingEmptySubsequences: true)
            .flatMap {
                $0.trimmingCharacters(in: .whitespaces)
                    .split(separator: ";", omittingEmptySubsequences: true)
                    .map { $0.trimmingCharacters(in: .whitespaces) }
            }
        guard let rateLimitField = items.first(where: { $0.contains(key) })?
            .replacingOccurrences(of: " ", with: "") else {
            throw RateLimitError.missingSearchKey(header: key)
        }
        let components = rateLimitField.split(separator: ":")
        var intValue: [Int] = []
        for component in components {
            if let number = Int(component) {
                intValue.append(number)
            }
        }
        guard intValue.count == 1 else {
            throw RateLimitError.dataPreparationError(countOfArray: intValue.count)
        }
        let result = intValue[0]
        if key == remaining {
            guard result > 0 else {
                throw RateLimitError.rateLimitExceeded(remaining: result)
            }
        }
        return result
    }
}

/// Possible errors thrown by `RateLimitMiddleware`.
public enum RateLimitError: Error {
    /// The specified search key was not found.
    case missingSearchKey(header: String?)
    /// An error occurred while preparing the data.
    case dataPreparationError(countOfArray: Int?)
    /// The client has exceeded the rate limit for the current period.
    case rateLimitExceeded(remaining: Int?)
}
