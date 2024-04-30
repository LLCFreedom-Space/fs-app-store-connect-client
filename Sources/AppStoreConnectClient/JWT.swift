//
//  JWT.swift
//
//
//  Created by Mykola Vasyk on 26.04.2024.
//

import Crypto
import Foundation

struct JWT {
    private let header: Header
    private var cachedToken: String? = nil
    private let privateKey: PrivateKey
    private let issuerIdentifier: String
    private let expireDuration: TimeInterval
    
    public init(
        keyID: String,
        privateKey: PrivateKey,
        issuerIdentifier: String,
        expireDuration: TimeInterval
    ) {
        self.header = Header(key: keyID)
        self.privateKey = privateKey
        self.issuerIdentifier = issuerIdentifier
        self.expireDuration = expireDuration
    }
    
    mutating func getToken() throws -> String {
        if let cachedToken = cachedToken, !JWT.isExpired(cachedToken) {
            return cachedToken
        } else {
            let newToken = try createToken()
            cachedToken = newToken
            return newToken
        }
    }
    
    private func createToken() throws -> String {
        let digest = try self.digest()
        let signature = try privateKey.sign(digest)
        return "\(digest).\(signature)"
    }
    
    private func digest() throws -> String {
        let now = Date()
        let payload = Payload(
            expirationTime: now.addingTimeInterval(expireDuration).timeIntervalSince1970,
            issuerId: issuerIdentifier,
            issuedAt: now.timeIntervalSince1970
        )
        
        let headerEncoded = try JSONEncoder().encode(header.self).base64EncodedString()
        let payloadEncoded = try JSONEncoder().encode(payload.self).base64EncodedString()
        let digest = "\(headerEncoded).\(payloadEncoded)"
        
        return digest
    }
    
    static func isExpired(_ token: String) -> Bool {
        do {
            let payload = try getPayload(from: token)
            let expiryDate = Date(timeIntervalSince1970: payload.expirationTime)
            let now = Date()
            
            return expiryDate < now
        } catch {
            return true
        }
    }
    
    static func getPayload(from token: String) throws -> JWT.Payload {
        let parts = token.components(separatedBy: ".")
        guard parts.count == 3 else {
            throw DecodingError.invalidPartCount(token, parts.count)
        }
        guard let payloadData = base64UrlDecode(parts[1]) else {
            throw DecodingError.invalidPayloadDecode
        }
        let decoder = JSONDecoder()
        return try decoder.decode(JWT.Payload.self, from: payloadData)
    }
    
    private static func base64UrlDecode(_ value: String) -> Data? {
        var base64 = value
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
        let requiredLength = 4 * ceil(length / 4.0)
        let paddingLength = requiredLength - length
        if paddingLength > 0 {
            let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
            base64 += padding
        }
        
        return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
    }
}

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
