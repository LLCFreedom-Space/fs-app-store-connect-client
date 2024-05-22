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
//  JWTError.swift
//  
//
//  Created by Mykola Vasyk on 02.05.2024.
//

import Foundation

/// An enumeration representing decoding errors that may occur during the decoding process of a JSON Web Token (JWT).
public enum JWTError: Error {
    /// Indicates that the JWT has an invalid number of parts.
    case invalidComponentsCount(String, Int)
    /// Indicates that there was an issue decoding the payload of the JWT.
    case invalidPayloadDecode
    /// The provided private key is invalid.
    case invalidPrivateKey
}
