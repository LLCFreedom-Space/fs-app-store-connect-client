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
//  RetryingMiddleware+Extensions.swift
//
//
//  Created by Mykola Vasyk on 17.05.2024.
//

import Foundation

/// The extension of middleware that retries the request under certain conditions.
extension RetryingMiddleware {
    /// The failure signal that can lead to a retried request.
    package enum RetryableSignal: Hashable {
        /// Retry if the response code matches this code.
        case code(Int)
        /// Retry if the response code falls into this range.
        case range(Range<Int>)
        /// Retry if an error is thrown by a downstream middleware or transport.
        case errorThrown
    }
    
    /// The policy to use when a retryable signal hints that a retry might be appropriate.
    package enum RetryingPolicy: Hashable {
        /// Don't retry.
        case never
        /// Retry up to the provided number of attempts.
        case upToAttempts(count: Int)
    }
    
    /// The policy of delaying the retried request.
    package enum DelayPolicy: Hashable {
        /// Don't delay, retry immediately.
        case none
        /// Constant delay.
        case constant(seconds: TimeInterval)
    }
}
