//
//  AppStoreConnectError.swift
//
//
//  Created by Mykola Vasyk on 19.04.2024.
//

import Foundation

/// An enumeration of errors that may occur during interactions with the App Store Connect API.
public enum AppStoreConnectError: Error {
    /// A server-side error occurred, indicated by the provided status code.
    case serverError(errorCode: Int)
    /// Invalid access token, indicated by App Store Connect server.
    case invalidToken
    /// No results were found for the specified bundle ID.
    case unauthorized
    
    case forbidden
    
    case badRequest
    
    case notFound
    
    case invalidJWT
}
