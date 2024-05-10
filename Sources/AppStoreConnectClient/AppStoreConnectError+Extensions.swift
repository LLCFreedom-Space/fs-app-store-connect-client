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
//  AppStoreConnectError+Extensions.swift
//  
//
//  Created by Mykola Vasyk on 10.05.2024.
//

import Foundation

extension AppStoreConnectError {
    /// Converts an error response into a formatted string.
    /// - Parameter response: The error response object.
    /// - Returns: A formatted string describing the error response, or `nil` if the response is empty.
    static func parseErrorDescription(from response: Components.Schemas.ErrorResponse) -> String? {
        var stringError = ""
        response.errors?.forEach { error in
            stringError.append("""
                \nFailed with: \(error.status), \(error.code), \(error.title), \(error.detail).
                """)
        }
        guard !stringError.isEmpty else {
            return nil
        }
        return stringError
    }
}
