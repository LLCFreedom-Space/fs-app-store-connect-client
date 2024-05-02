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
//  JWT.swift
//
//
//  Created by Mykola Vasyk on 26.04.2024.
//

import Crypto
import Foundation

/// JWT (JSON Web Token) provides a way to securely transmit information between parties as a JSON object.
internal struct JWT {
    /// The header containing metadata about the token.
    private let header: Header
    /// The private key used for signing the token.
    private let privateKey: PrivateKey
    /// The identifier of the issuer.
    private let issuerIdentifier: String
    /// The duration until the token expires.
    private let expireDuration: TimeInterval
    
    /// Initializes a JWT instance.
    /// - Parameters:
    ///   - keyID: The identifier for the key.
    ///   - privateKey: The private key used for signing the token.
    ///   - issuerIdentifier: The identifier of the issuer.
    ///   - expireDuration: The duration until the token expires.
    init(
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
    /// Creates a JWT token using the provided credentials.
    /// - Parameter credentials: The credentials required for generating the token.
    /// - Returns: The generated JWT token.
    /// - Throws: An error if token creation fails.
    static func createToken(by credentials: Credentials) throws -> String {
        let privateKey = try JWT.PrivateKey(pemRepresentation: credentials.privateKey)
        let jwt = JWT(
            keyID: credentials.keyId,
            privateKey: privateKey,
            issuerIdentifier: credentials.issuerId,
            expireDuration: credentials.expireDuration
        )
        let digest = try jwt.digest()
        let signature = try privateKey.sign(digest)
        return "\(digest).\(signature)"
    }
    
    /// Calculates the digest of the token.
    /// - Returns: The digest of the token.
    /// - Throws: An error if digest calculation fails.
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
    
    /// Verifies if the token has expired.
    /// - Parameter token: The JWT token to verify.
    /// - Returns: A boolean indicating whether the token is not expired.
    static func verifyNotExpired(_ token: String) -> Bool {
        do {
            let payload = try getPayload(from: token)
            let expiryDate = Date(timeIntervalSince1970: payload.expirationTime)
            let now = Date()
            return expiryDate > now
        } catch {
            return false
        }
    }
    
    /// Retrieves the payload from a JWT token.
    /// - Parameter token: The JWT token from which to extract the payload.
    /// - Returns: The extracted payload.
    /// - Throws: An error if payload extraction fails.
    private static func getPayload(from token: String) throws -> JWT.Payload {
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
    
    /// Decodes a base64 URL encoded string.
    /// - Parameter value: The base64 URL encoded string.
    /// - Returns: The decoded data.
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
