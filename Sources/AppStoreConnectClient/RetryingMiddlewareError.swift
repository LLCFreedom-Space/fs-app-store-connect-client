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
//  RetryingMiddlewareError.swift
//  
//
//  Created by Mykola Vasyk on 21.05.2024.
//

import Foundation

/// Possible errors thrown by `RetryingMiddleware`.
public enum RetryingMiddlewareError: Error, Equatable {
    /// An error indicating that the operation has reached the maximum number of retry attempts.
    case maxAttemptsReached
    /// An error indicating that the operation has failed and triggered a retry.
    case error
}
