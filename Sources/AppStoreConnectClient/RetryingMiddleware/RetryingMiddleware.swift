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
//  RetryingMiddleware.swift
//
//
//  Created by Mykola Vasyk on 11.05.2024.
//

import OpenAPIRuntime
import Foundation
import HTTPTypes

/// A middleware for retrying failed HTTP requests based on configurable signals and policies.
package struct RetryingMiddleware {
    /// Initialization HTTP errors with a code of 429
    private static let tooManyRequests = 429
    /// Initialization HTTP errors with a code of 500
    private static let internalServerError = 500
    /// Initialization HTTP errors with a code of 600
    private static let logicError = 600
    
    /// Set of retryable signals triggering retries.
    package var signals: Set<RetryableSignal> = [
        .code(
            RetryingMiddleware.tooManyRequests
        ),
        .range(RetryingMiddleware.internalServerError..<RetryingMiddleware.logicError),
        .errorThrown
    ]
    /// Retry policy for the middleware.
    package var policy: RetryingPolicy = .upToAttempts(count: 3)
    /// Delay policy for the middleware.
    package var delay: DelayPolicy = .constant(seconds: 1)
}

extension RetryingMiddleware: ClientMiddleware {
    /// Intercepts and potentially retries HTTP requests.
    /// - Parameters:
    ///   - request: The HTTP request to intercept.
    ///   - body: The body of the HTTP request.
    ///   - baseURL: The base URL of the request.
    ///   - operationID: The operation ID associated with the request.
    ///   - next: The closure representing the next middleware or endpoint in the chain.
    /// - Returns: A tuple containing the HTTP response and body, if successful.
    /// - Throws: An error if the request fails after all retry attempts.
    package func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        // Check if the retry policy is set to number of attempts
        guard case .upToAttempts(count: let maxAttemptCount) = policy else {
            return try await next(request, body, baseURL)
        }
        // Check if there is a body to the request
        if let body {
            // Ensure the request body can be sent multiple times
            guard body.iterationBehavior == .multiple else {
                return try await next(request, body, baseURL)
            }
        }
        // Perform an initial retry delay if necessary
        try await willRetry()
        // Loop for the maximum number of attempts
        for attempt in 1...maxAttemptCount {
            // Initialize variables for response and response body
            let (response, responseBody): (HTTPResponse, HTTPBody?)
            // Check if should retry after an error
            if signals.contains(.errorThrown) {
                do {
                    (response, responseBody) = try await next(request, body, baseURL)
                } catch {
                    // If the final attempt fails, throw the error
                    if attempt == maxAttemptCount {
                        throw RetryingError.maxAttemptsReached
                    } else {
                        // Wait before retrying the operation
                        try await willRetry()
                        continue
                    }
                }
            } else {
                (response, responseBody) = try await next(request, body, baseURL)
            }
            // Check if the response status code indicates a retry and if max attempts are not reached
            if signals.contains(response.status.code) && attempt < maxAttemptCount {
                try await willRetry()
                continue
            } else {
                return (response, responseBody)
            }
        }
        // This point should never be reached
        preconditionFailure("Unreachable")
    }
    
    /// Pauses execution based on the specified delay policy before retrying an operation.
    private func willRetry() async throws {
        let nanosecondsPerSecond: TimeInterval = 1_000_000_000
        switch delay {
            /// No delay before retrying the operation.
        case .none: return
            /// Constant delay before retrying the operation.
        case .constant(seconds: let seconds):
            try await Task.sleep(nanoseconds: UInt64(seconds * nanosecondsPerSecond))
        }
    }
}
