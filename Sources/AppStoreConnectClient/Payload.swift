//
//  Payload.swift
//  
//
//  Created by Mykola Vasyk on 22.04.2024.
//

import Foundation
import JWTKit

public struct Payload: JWTPayload {
    var issueID: IssuerClaim
    var expiration: ExpirationClaim
    var audience: AudienceClaim
    
    public func verify(using signer: JWTSigner) throws {
        try expiration.verifyNotExpired()
    }
    
    private enum CodingKeys: String, CodingKey {
        case issueID = "iss"
        case expiration = "exp"
        case audience = "aud"
    }
}
