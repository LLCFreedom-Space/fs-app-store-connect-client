//
//  JWTKeyCollection.swift
//
//
//  Created by Mykola Vasyk on 26.04.2024.
//

import OpenAPIRuntime
import Foundation
import HTTPTypes
import JWTKit
import Crypto

public protocol Authenticator {
    mutating func token() throws -> String
}

public struct JWT: Authenticator {
    struct Header: Codable, Equatable {
        let type: String = "JWT"

        let algorithm: String = "ES256"

        var key: String

        private enum CodingKeys: String, CodingKey {
            case type = "typ"
            case key = "kid"
            case algorithm = "alg"
        }
    }

//    /// Claims about the authenticating user.
//    struct Payload: JWTPayload, Codable, Equatable {
//        func verify(using signer: JWTSigner) throws {
//            try expiration.verifyNotExpired()
//        }
//        let audience: String = "appstoreconnect-v1"
//        var issuer: String
//        var issuedAt: TimeInterval?
//
//        var expiration: ExpirationClaim
//        var scope: [String]?
//
//        private enum CodingKeys: String, CodingKey {
//            case audience = "aud"
//            case issuer = "iss"
//            case issuedAt = "iat"
//            case expiration = "exp"
//            case scope
//        }
//    }

    public struct PrivateKey {
        var key: P256.Signing.PrivateKey

        public init(
            pemRepresentation: String
        ) throws {
            self.key = try P256.Signing.PrivateKey(pemRepresentation: pemRepresentation)
        }

        public init(
            contentsOf url: URL
        ) throws {
            let pemRepresentation = try String(contentsOf: url, encoding: .utf8)
            try self.init(pemRepresentation: pemRepresentation)
        }

        func sign(_ digest: String) throws -> String {
            let signature = try key.signature(for: Data(digest.utf8))

            return String(base64Encode: signature.rawRepresentation)
        }
    }

    enum DecodingError: Error, Equatable {
        struct Context: Equatable, CustomDebugStringConvertible {
            var debugDescription: String
        }
        case dataCorrupted(Context)
    }

    var header: Header

    var issuer: String

    var issuedAt: TimeInterval?

    var expiryDuration: TimeInterval

    var scopes: [String]?

    var privateKey: PrivateKey

    private var date: () -> Date

    private var cachedToken: String?
    
    var expirationClaim: ExpirationClaim //?

    public init(
        keyID: String,
        issuerID: String,
        issuedAt: TimeInterval? = nil,
        expiryDuration: TimeInterval,
        scopes: [String]? = nil,
        privateKey: PrivateKey,
        expirationClaim: ExpirationClaim
    ) {
        self.init(
            keyID: keyID,
            issuerID: issuerID,
            issuedAt: issuedAt,
            expiryDuration: expiryDuration,
            scopes: scopes,
            privateKey: privateKey,
            date: Date.init(),
            expirationClaim: expirationClaim
        )
    }

    init(
        keyID: String,
        issuerID: String,
        issuedAt: TimeInterval? = nil,
        expiryDuration: TimeInterval,
        scopes: [String]? = nil,
        privateKey: PrivateKey,
        date: @autoclosure @escaping () -> Date,
        expirationClaim: ExpirationClaim
    ) {
        self.header = Header(key: keyID)
        self.issuer = issuerID
        self.issuedAt = issuedAt
        self.expiryDuration = expiryDuration
        self.scopes = scopes
        self.privateKey = privateKey
        self.date = date
        self.expirationClaim = expirationClaim
    }

    public mutating func token() throws -> String {
        if let cachedToken = cachedToken, !JWT.isExpired(cachedToken, date: date()) {
            return cachedToken
        }

        let newToken = try encode()
        cachedToken = newToken

        return newToken
    }

    func encode() throws -> String {
        let digest = try self.digest()
        let signature = try privateKey.sign(digest)

        return "\(digest).\(signature)"
    }

    func digest() throws -> String {
        let now = date()
        let expirationDate = now.addingTimeInterval(expiryDuration)
        let expirationClaim = ExpirationClaim(value: expirationDate)
        let payload = Payload(
            issuer: issuer,
            issuedAt: issuedAt,
            expiration: expirationClaim,
            scope: scopes
        )

        let encoder = JSONEncoder()
        let headerEncoded = try String(base64Encode: encoder.encode(header))
        let payloadEncoded = try String(base64Encode: encoder.encode(payload))
        let digest = "\(headerEncoded).\(payloadEncoded)"

        return digest
    }

    static func isExpired(_ token: String, date: @autoclosure () -> Date) -> Bool {
        do {
            let (_, payload) = try decode(from: token)
            let expiryDate = Date(timeIntervalSince1970: payload.expiration.value.timeIntervalSince1970) //?
            let now = date()

            return expiryDate < now
        } catch {
            return true
        }
    }

    static func decode(from token: String) throws -> (Header, Payload) {
        let parts = token.components(separatedBy: ".")
        guard parts.count == 3 else {
            throw DecodingError.dataCorrupted(
                .init(
                    debugDescription: "Invalid part count: expected 3, found \(parts.count)"
                )
            )
        }

        guard let headerData = Data(base64Decode: parts[0]) else {
            throw DecodingError.dataCorrupted(
                .init(
                    debugDescription: "Header data could not be base64-decoded"
                )
            )
        }

        guard let payloadData = Data(base64Decode: parts[1]) else {
            throw DecodingError.dataCorrupted(
                .init(
                    debugDescription: "Payload data could not be base64-decoded"
                )
            )
        }

        let decoder = JSONDecoder()

        return try (
            decoder.decode(Header.self, from: headerData),
            decoder.decode(Payload.self, from: payloadData)
        )
    }
}

extension String {
    init(
        base64Encode data: Data
    ) {
        self = data.base64EncodedString()
            .replacingOccurrences(of: "=", with: "")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
    }
}

extension Data {
    init?(
        base64Decode string: String
    ) {
        var base64 =
            string
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
        let requiredLength = 4 * ceil(length / 4.0)
        let paddingLength = requiredLength - length
        if paddingLength > 0 {
            let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
            base64 += padding
        }

        self.init(base64Encoded: base64, options: .ignoreUnknownCharacters)
    }
}
