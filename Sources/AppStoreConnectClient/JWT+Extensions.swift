//
//  File.swift
//  
//
//  Created by Mykola Vasyk on 01.05.2024.
//

import Foundation
import Crypto

extension JWT {
    struct Header: Codable {
        let type: String = "JWT"
        let algorithm: String = "ES256"
        let key: String
        
        private enum CodingKeys: String, CodingKey {
            case type = "typ"
            case key = "kid"
            case algorithm = "alg"
        }
    }
}

extension JWT {
    struct Payload: Codable {
        let audience: String = "appstoreconnect-v1"
        let expirationTime: TimeInterval
        let issuerId: String
        let issuedAt: TimeInterval?
        
        private enum CodingKeys: String, CodingKey {
            case audience = "aud"
            case issuerId = "iss"
            case issuedAt = "iat"
            case expirationTime = "exp"
        }
    }
}

extension JWT {
    public struct PrivateKey {
        let key: P256.Signing.PrivateKey
        
        public init(
            pemRepresentation: String
        ) throws {
            do {
                self.key = try P256.Signing.PrivateKey(pemRepresentation: pemRepresentation)
            } catch {
                throw AppStoreConnectError.invalidPrivateKey
            }
        }
        
        func sign(_ digest: String) throws -> String {
            let signature = try key.signature(for: Data(digest.utf8))
            return signature.rawRepresentation.base64EncodedString()
                .replacingOccurrences(of: "=", with: "")
                .replacingOccurrences(of: "+", with: "-")
                .replacingOccurrences(of: "/", with: "_")
        }
    }
}
