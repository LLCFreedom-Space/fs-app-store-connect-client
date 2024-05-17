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
//  RateLimitMiddlewareError.swift
//  
//
//  Created by Mykola Vasyk on 17.05.2024.
//

import Foundation

/// Possible errors thrown by `RateLimitMiddleware`.
public enum RateLimitError: Error, Equatable {
    /// The specified search header was not found.
    case headerValidationFailed(header: String?)
    /// The client has exceeded the rate limit for the values.
    case rateLimitExceeded(remaining: Int, from: Int)
    /// Unable to extract values of rate limit.
    case invalidExpectedValues(String?)
}
