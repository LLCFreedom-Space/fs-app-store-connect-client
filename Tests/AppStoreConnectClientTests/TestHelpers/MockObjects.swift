//
//  MockObjects.swift
//
//
//  Created by Mykola Vasyk on 22.04.2024.
//

import Foundation
import OpenAPIRuntime
@testable import AppStoreConnectClient

enum MockObjects {
    static var errorResponse: Components.Schemas.ErrorResponse {
        let response = Components.Schemas.ErrorResponse(
            errors: Components.Schemas.ErrorResponse.errorsPayload()
        )
        return response
    }
    
    static var appStoreVersionsResponse: Components.Schemas.AppStoreVersionsResponse {
        let response = Components.Schemas.AppStoreVersionsResponse(
            data: [appStoreVersion],
            links: Components.Schemas.PagedDocumentLinks(_self: "")
        )
        return response
    }
    
    static var appsResponse: Components.Schemas.AppsResponse {
        let response = Components.Schemas.AppsResponse(
            data: [app],
            links: Components.Schemas.PagedDocumentLinks(_self: "")
        )
        return response
    }
    
    static var app: Components.Schemas.App {
        let response = Components.Schemas.App(
            _type: .apps,
            id: "1234567",
            attributes: Components.Schemas.App.attributesPayload(bundleId: "com.example.app")
        )
        return response
    }
    
    static var appStoreVersion: Components.Schemas.AppStoreVersion {
        let response = Components.Schemas.AppStoreVersion(
            _type: .appStoreVersions,
            id: app.id,
            attributes: Components.Schemas.AppStoreVersion.attributesPayload(
                versionString: "1.1.1",
                appStoreState: .ACCEPTED
            )
        )
        return response
    }
    
    static let appStoreVersionResponse: [AppStoreVersionResponse] = [
        AppStoreVersionResponse(
            id: app.id,
            appStoreState: .readyForSale,
            appVersionState: .readyForDistribution,
            platform: .iOS,
            versionString: appStoreVersion.attributes?.versionString ?? "1.1.1"
        )
    ]
}

struct AppStoreVersionResponse {
    let id: String
    let appStoreState: AppStoreState
    let appVersionState: AppVersionState
    let platform: Platform
    let versionString: String
}

enum AppStoreState: String {
    case accepted = "ACCEPTED"
    case readyForSale = "READY_FOR_SALE"
    case rejected = "REJECTED"
}

enum AppVersionState: String {
    case accepted = "ACCEPTED"
    case readyForDistribution = "READY_FOR_DISTRIBUTION"
    case readyForReview = "READY_FOR_REVIEW"
    case rejected = "REJECTED"
}

enum Platform: String {
    case iOS = "IOS"
    case macOS = "MAC_OS"
    case tvOS = "TV_OS"
    case visionOS = "VISION_OS"
}
