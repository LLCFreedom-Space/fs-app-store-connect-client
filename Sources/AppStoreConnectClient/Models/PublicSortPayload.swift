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
//  PublicSortPayload.swift
//
//
//  Created by Mykola Vasyk on 11.06.2024.
//

import Foundation

/// Represents a wrapper for sort payload used in the builds collection query.
public struct PublicSortPayload {
    /// The internal sort payload used in the builds collection query.
    let internalPayload: Operations.builds_hyphen_get_collection.Input.Query.sortPayload
    
    /// Initializes a `PublicSortPayload` with the provided internal sort payload.
    /// - Parameter schema: The internal sort payload.
    init(schema: Operations.builds_hyphen_get_collection.Input.Query.sortPayload) {
        self.internalPayload = schema
    }
    
    /// Creates a `PublicSortPayload` for sorting by hyphen version.
    /// - Returns: An instance of `PublicSortPayload` configured for sorting by hyphen version.
    public static func hyphenVersion() -> PublicSortPayload {
        return PublicSortPayload(schema: .init([._hyphen_version]))
    }
}
