//
//  Payload.swift
//
//
//  Created by Mykola Vasyk on 22.04.2024.
//

import Foundation
import JWTKit

/// Represents a payload structure conforming to the JWTPayload protocol.
/// This structure contains claims related to JWT such as issuer, expiration, and audience.
 struct Payload: JWTPayload {
    /// Represents the issuer claim.
    var issueID: IssuerClaim
    /// Represents the expiration claim.
    var expiration: ExpirationClaim
    /// Represents the audience claim.
    var audience: AudienceClaim
    
    /// Verifies the payload using the provided JWTSigner.
    /// - Parameter signer: The JWTSigner instance used for verification.
    /// - Throws: Throws an error if the payload verification fails.
    func verify(using signer: JWTSigner) throws {
        try expiration.verifyNotExpired()
    }
    
    /// Coding keys for encoding and decoding the payload.
    private enum CodingKeys: String, CodingKey {
        case issueID = "iss"
        case expiration = "exp"
        case audience = "aud"
    }
}
