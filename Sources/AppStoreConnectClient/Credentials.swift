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
