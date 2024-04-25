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
//  Credentials.swift
//
//
//  Created by Mykola Vasyk on 22.04.2024.
//

import Foundation

/// Represents the credentials required for authenticating with the App Store Connect API using JWT.
public struct Credentials: Sendable {
    /// The issuer identifier.
    let issuerId: String
    /// The private key identifier.
    let keyId: String
    /// The private key.
    let privateKey: String
}
