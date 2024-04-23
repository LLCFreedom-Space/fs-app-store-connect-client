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
        let response = Components.Schemas.ErrorResponse(errors: Components.Schemas.ErrorResponse.errorsPayload())
        return response
    }
    static var errorSourceParameter: Components.Schemas.ErrorResponse.errorsPayload {
        let response = Components.Schemas.ErrorResponse.errorsPayload()
        return response
    }
    static var appStoreVersionsResponse: Components.Schemas.AppStoreVersionsResponse {
        let response = Components.Schemas.AppStoreVersionsResponse(data: [appStoreVersion], links: Components.Schemas.PagedDocumentLinks(_self: ""))
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
            versionString: appStoreVersion.attributes?.versionString ?? "1.1.1",
            ageRatingDeclarations: AgeRatingDeclarations(
                ageRatingOverride: false,
                alcoholTobaccoOrDrugUseOrReferences: false,
                contests: false,
                gambling: false,
                gamblingAndContests: false,
                gamblingSimulated: false,
                horrorOrFearThemes: false,
                kidsAgeBand: .ages9AndUnder,
                matureOrSuggestiveThemes: false,
                medicalOrTreatmentInformation: false,
                profanityOrCrudeHumor: false,
                seventeenPlus: false,
                sexualContentGraphicAndNudity: false,
                sexualContentOrNudity: false,
                unrestrictedWebAccess: false,
                violenceCartoonOrFantasy: false,
                violenceRealistic: false,
                violenceRealisticProlongedGraphicOrSadistic: false
            ),
            appStoreReviewDetails: AppStoreReviewDetails(
                appStoreReviewAttachments: false,
                appStoreVersion: "1.1.1",
                contactEmail: "contact@example.com",
                contactFirstName: "John",
                contactLastName: "Doe",
                contactPhone: "+1234567890",
                demoAccountName: "demo",
                demoAccountPassword: "password",
                demoAccountRequired: false,
                notes: "Some notes here"
            ),
            appStoreVersionLocalizations: AppStoreVersionLocalizations(
                appPreviewSets: [],
                appScreenshotSets: [],
                appStoreVersion: "1.1.1",
                description: "This is the app description",
                keywords: ["keyword1", "keyword2"],
                locale: "en-US",
                marketingUrl: "https://example.com",
                promotionalText: "Promotional text here",
                supportUrl: "https://example.com/support",
                whatsNew: "What's new in this version"
            )
        )
    ]
}

struct AppStoreVersionResponse {
    let id: String
    let appStoreState: AppStoreState
    let appVersionState: AppVersionState
    let platform: Platform
    let versionString: String
    let ageRatingDeclarations: AgeRatingDeclarations
    let appStoreReviewDetails: AppStoreReviewDetails
    let appStoreVersionLocalizations: AppStoreVersionLocalizations
}

struct AgeRatingDeclarations {
    let ageRatingOverride: Bool
    let alcoholTobaccoOrDrugUseOrReferences: Bool
    let contests: Bool
    let gambling: Bool
    let gamblingAndContests: Bool
    let gamblingSimulated: Bool
    let horrorOrFearThemes: Bool
    let kidsAgeBand: KidsAgeBand
    let matureOrSuggestiveThemes: Bool
    let medicalOrTreatmentInformation: Bool
    let profanityOrCrudeHumor: Bool
    let seventeenPlus: Bool
    let sexualContentGraphicAndNudity: Bool
    let sexualContentOrNudity: Bool
    let unrestrictedWebAccess: Bool
    let violenceCartoonOrFantasy: Bool
    let violenceRealistic: Bool
    let violenceRealisticProlongedGraphicOrSadistic: Bool
}

enum AppStoreState: String {
    case accepted = "ACCEPTED"
    case developerRemovedFromSale = "DEVELOPER_REMOVED_FROM_SALE"
    case developerRejected = "DEVELOPER_REJECTED"
    case inReview = "IN_REVIEW"
    case invalidBinary = "INVALID_BINARY"
    case metadataRejected = "METADATA_REJECTED"
    case pendingAppleRelease = "PENDING_APPLE_RELEASE"
    case pendingContract = "PENDING_CONTRACT"
    case pendingDeveloperRelease = "PENDING_DEVELOPER_RELEASE"
    case prepareForSubmission = "PREPARE_FOR_SUBMISSION"
    case preorderReadyForSale = "PREORDER_READY_FOR_SALE"
    case processingForAppStore = "PROCESSING_FOR_APP_STORE"
    case readyForReview = "READY_FOR_REVIEW"
    case readyForSale = "READY_FOR_SALE"
    case rejected = "REJECTED"
    case removedFromSale = "REMOVED_FROM_SALE"
    case waitingForExportCompliance = "WAITING_FOR_EXPORT_COMPLIANCE"
    case waitingForReview = "WAITING_FOR_REVIEW"
    case replacedWithNewVersion = "REPLACED_WITH_NEW_VERSION"
    case notApplicable = "NOT_APPLICABLE"
}

enum AppVersionState: String {
    case accepted = "ACCEPTED"
    case developerRejected = "DEVELOPER_REJECTED"
    case inReview = "IN_REVIEW"
    case invalidBinary = "INVALID_BINARY"
    case metadataRejected = "METADATA_REJECTED"
    case pendingAppleRelease = "PENDING_APPLE_RELEASE"
    case pendingDeveloperRelease = "PENDING_DEVELOPER_RELEASE"
    case prepareForSubmission = "PREPARE_FOR_SUBMISSION"
    case processingForDistribution = "PROCESSING_FOR_DISTRIBUTION"
    case readyForDistribution = "READY_FOR_DISTRIBUTION"
    case readyForReview = "READY_FOR_REVIEW"
    case rejected = "REJECTED"
    case replacedWithNewVersion = "REPLACED_WITH_NEW_VERSION"
    case waitingForExportCompliance = "WAITING_FOR_EXPORT_COMPLIANCE"
    case waitingForReview = "WAITING_FOR_REVIEW"
}

enum Platform: String {
    case iOS = "IOS"
    case macOS = "MAC_OS"
    case tvOS = "TV_OS"
    case visionOS = "VISION_OS"
}

enum KidsAgeBand: String {
    case ages9AndUnder
}

struct AppStoreReviewDetails {
    let appStoreReviewAttachments: Bool
    let appStoreVersion: String
    let contactEmail: String
    let contactFirstName: String
    let contactLastName: String
    let contactPhone: String
    let demoAccountName: String
    let demoAccountPassword: String
    let demoAccountRequired: Bool
    let notes: String
}

struct AppStoreVersionLocalizations {
    let appPreviewSets: [String]
    let appScreenshotSets: [String]
    let appStoreVersion: String
    let description: String
    let keywords: [String]
    let locale: String
    let marketingUrl: String
    let promotionalText: String
    let supportUrl: String
    let whatsNew: String
}
