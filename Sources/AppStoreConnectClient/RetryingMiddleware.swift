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
    static let error429 = 429
    static let error500 = 500
    static let error600 = 600
    /// Signals that indicate when a retry should be attempted.
    package enum RetryableSignal: Hashable {
        case code(Int)
        case range(Range<Int>)
        case errorThrown
    }
    
    /// Policies dictating when and how many times to retry requests.
    package enum RetryingPolicy: Hashable {
        case never
        case upToAttempts(count: Int)
    }
    
    /// Policies determining the delay between retries.
    package enum DelayPolicy: Hashable {
        case none
        case constant(seconds: TimeInterval)
    }
    
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
        signals: Set<RetryableSignal> = [.code(error429), .range(error500..<error600), .errorThrown],
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
        func willRetry() async throws {
            switch delay {
            case .none: return
            case .constant(seconds: let seconds): 
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            }
        }
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
}

extension Set where Element == RetryingMiddleware.RetryableSignal {
    /// Checks if the set contains a retryable signal corresponding to a given HTTP status code.
    /// - Parameter code: The HTTP status code to check.
    /// - Returns: `true` if the set contains a retryable signal for the code, `false` otherwise.
    func contains(_ code: Int) -> Bool {
        for signal in self {
            switch signal {
            case .code(let int): if code == int {
                return true
            }
            case .range(let range): if range.contains(code) {
                return true
            }
            case .errorThrown: break
            }
        }
        return false
    }
}
