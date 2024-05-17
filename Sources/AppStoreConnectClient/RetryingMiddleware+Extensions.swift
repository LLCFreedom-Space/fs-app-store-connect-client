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

extension RetryingMiddleware {
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
