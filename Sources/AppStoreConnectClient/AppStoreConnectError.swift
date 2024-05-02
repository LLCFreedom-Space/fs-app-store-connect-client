//
//  AppStoreConnectError.swift
//
//
//  Created by Mykola Vasyk on 19.04.2024.
//

import Foundation

/// An enumeration of errors that may occur during interactions with the App Store Connect API.
public enum AppStoreConnectError: Error, Equatable {
    /// A server-side error occurred, indicated by the provided status code.
    case serverError(errorCode: Int)
    /// No results were found for the specified bundle ID.
    case unauthorized
    /// The request is forbidden.
    case forbidden
    /// The request is malformed or contains invalid parameters.
    case badRequest
    /// The requested resource was not found.
    case notFound
    /// The provided private key is invalid.
    case invalidPrivateKey
    /// The provided payload is invalid.
    case invalidSign
    /// The credentials is empty.
    case noHaveCredentials
}

/// An enumeration representing decoding errors that may occur during the decoding process of a JSON Web Token (JWT).
public enum DecodingError: Error {
    /// Indicates that the JWT has an invalid number of parts.
    case invalidPartCount(String, Int)
    /// Indicates that there was an issue decoding the payload of the JWT.
    case invalidPayloadDecode
}
