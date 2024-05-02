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
//  JWT+Extensions.swift
//
//
//  Created by Mykola Vasyk on 01.05.2024.
//

import Foundation
import Crypto

/// Extension for JWT functionality of Header
extension JWT {
    /// Struct representing the header of a JWT token conforming to Codable protocol.
    /// The header contains metadata about the token such as its type, algorithm, and key.
    struct Header: Codable {
        /// The type of the token.
        let type: String = "JWT"
        /// The algorithm used for signing the token.
        let algorithm: String = "ES256"
        /// The key identifier.
        let key: String
        
        /// Coding keys for custom JSON encoding/decoding.
        private enum CodingKeys: String, CodingKey {
            case type = "typ"
            case key = "kid"
            case algorithm = "alg"
        }
    }
}

/// Extension for JWT functionality of Payload.
extension JWT {
    /// Struct representing the payload of a JWT token conforming to Codable protocol.
    /// The payload contains information about the audience, expiration time, issuer identifier, and issued at time.
    struct Payload: Codable {
        /// The audience for the token.
        let audience: String = "appstoreconnect-v1"
        /// The expiration time of the token.
        let expiration: TimeInterval
        /// The identifier of the issuer.
        let issuerId: String
        /// The time at which the token was issued.
        let issuedAt: TimeInterval?
        
        /// Coding keys for custom JSON encoding/decoding.
        private enum CodingKeys: String, CodingKey {
            case audience = "aud"
            case issuerId = "iss"
            case issuedAt = "iat"
            case expiration = "exp"
        }
    }
}

/// Extension for JWT functionality of PrivateKey
extension JWT {
    /// Struct representing a private key used for signing JWT tokens.
    public struct PrivateKey {
        /// The private key for signing.
        let key: P256.Signing.PrivateKey
        
        /// Initializes a private key with the provided PEM representation.
        /// - Parameter pemRepresentation: The PEM representation of the private key.
        /// - Throws: An error if initialization fails due to an invalid private key.
        public init(
            pemRepresentation: String
        ) throws {
            do {
                self.key = try P256.Signing.PrivateKey(pemRepresentation: pemRepresentation)
            } catch {
                throw JWTError.invalidPrivateKey
            }
        }
        
        /// Signs the provided digest using the private key.
        /// - Parameter digest: The digest to sign.
        /// - Returns: The signature of the digest.
        /// - Throws: An error if signing fails.
        func sign(_ digest: String) throws -> String {
            let signature = try key.signature(for: Data(digest.utf8))
            return signature.rawRepresentation.base64EncodedString()
                .replacingOccurrences(of: "=", with: "")
                .replacingOccurrences(of: "+", with: "-")
                .replacingOccurrences(of: "/", with: "_")
        }
    }
}
