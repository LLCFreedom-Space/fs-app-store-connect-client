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
    /// Init errors
    private static let tooManyRequests = 429
    private static let internalServerError = 500
    private static let logicError = 600
    
    /// Set of retryable signals triggering retries.
    package var signals: Set<RetryableSignal>
    /// Retry policy for the middleware.
    package var policy: RetryingPolicy
    /// Delay policy for the middleware.
    package var delay: DelayPolicy
    
    /// Initializes the retrying middleware with default values.
    /// - Parameters:
    ///   - signals: Set of retryable signals. Defaults to common error codes and thrown errors.
    ///   - policy: Retry policy. Defaults to retrying up to 3 attempts.
    ///   - delay: Delay policy between retry attempts. Defaults to a constant delay of 1 second.
    package init(
        signals: Set<RetryableSignal> = [
            .code(
                tooManyRequests
            ),
            .range(internalServerError..<logicError),
            .errorThrown
        ],
        policy: RetryingPolicy = .upToAttempts(count: 3),
        delay: DelayPolicy = .constant(seconds: 1)
    ) {
        self.signals = signals
        self.policy = policy
        self.delay = delay
    }
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
        guard case .upToAttempts(count: let maxAttemptCount) = policy else {
            return try await next(request, body, baseURL)
        }
        if let body {
            guard body.iterationBehavior == .multiple else {
                return try await next(request, body, baseURL)
            }
        }
        try await willRetry()
        for attempt in 1...maxAttemptCount {
            let (response, responseBody): (HTTPResponse, HTTPBody?)
            if signals.contains(.errorThrown) {
                do {
                    (response, responseBody) = try await next(request, body, baseURL)
                } catch {
                    if attempt == maxAttemptCount {
                        throw error
                    } else {
                        try await willRetry()
                        continue
                    }
                }
            } else {
                (response, responseBody) = try await next(request, body, baseURL)
            }
            if signals.contains(response.status.code) && attempt < maxAttemptCount {
                try await willRetry()
                continue
            } else {
                return (response, responseBody)
            }
        }
        preconditionFailure("Unreachable")
    }
    
    func willRetry() async throws {
        switch delay {
        case .none: return
        case .constant(seconds: let seconds):
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
        }
    }
}
