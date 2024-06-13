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
//  BuildsQuery.swift
//
//
//  Created by Mykola Vasyk on 12.06.2024.
//

import Foundation

/// A structure representing a query for builds with specified sort and fields parameters.
public struct BuildsQuery {
    /// The sort payload for the query.
    let sort: Operations.builds_hyphen_get_collection.Input.Query.sortPayload
    /// The fields payload for the query.
    let fields: Operations.builds_hyphen_get_collection.Input.Query.fields_lbrack_builds_rbrack_Payload
}
