//
//  File.swift
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
        let expirationTime: TimeInterval
        /// The identifier of the issuer.
        let issuerId: String
        /// The time at which the token was issued.
        let issuedAt: TimeInterval?
        
        /// Coding keys for custom JSON encoding/decoding.
        private enum CodingKeys: String, CodingKey {
            case audience = "aud"
            case issuerId = "iss"
            case issuedAt = "iat"
            case expirationTime = "exp"
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
                throw AppStoreConnectError.invalidPrivateKey
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
