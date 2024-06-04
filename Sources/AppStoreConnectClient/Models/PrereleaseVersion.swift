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
//  PrereleaseVersion.swift
//  
//
//  Created by Mykola Vasyk on 29.05.2024.
//

import Foundation

public struct PrereleaseVersion {
    let betaTester: Components.Schemas.BetaTester
    let betaGroup: Components.Schemas.BetaGroup
    let betaBuildLocalization: Components.Schemas.BetaBuildLocalization
    let appEncryptionDeclaration: Components.Schemas.AppEncryptionDeclaration
    let betaAppReview: Components.Schemas.BetaAppReviewSubmission
    let app: Components.Schemas.App
    let buildBetaDetail: Components.Schemas.BuildBetaDetail
    let buildBundle: Components.Schemas.BuildBundle
    
//    init(
//        betaTester: Components.Schemas.BetaTester,
//        betaGroup: Components.Schemas.BetaGroup,
//        betaBuildLocalization: Components.Schemas.BetaBuildLocalization,
//        appEncryptionDeclaration: Components.Schemas.AppEncryptionDeclaration,
//        betaAppReview: Components.Schemas.BetaAppReviewSubmission,
//        app: Components.Schemas.App,
//        buildBetaDetail: Components.Schemas.BuildBetaDetail,
//        buildBundle: Components.Schemas.BuildBundle
//    ) {
//        self.betaTester = betaTester.attributes?.email
//        self.betaGroup = betaGroup.attributes?.name
//        self.betaBuildLocalization = betaBuildLocalization.attributes?.locale
//        self.appEncryptionDeclaration = appEncryptionDeclaration.attributes?.appDescription
//        self.betaAppReview = betaAppReview.attributes?.betaReviewState?.rawValue
//        self.app = app.attributes?.bundleId
//        self.buildBetaDetail = buildBetaDetail.id
//        self.buildBundle = buildBundle.attributes?.bundleId // .platformBuild
//    }
}
    
//    public let ios: String?
//    public let macOs: String?
//    let buildEligible: String?                 /*filter_lbrack_buildAudienceType_rbrack_: ,*/
//    public let betaReview: String? .init(arrayLiteral: T##Operations.builds_hyphen_get_collection.Input.Query.filter_lbrack_betaAppReviewSubmission_period_betaReviewState_rbrack_PayloadPayload...##Operations.builds_hyphen_get_collection.Input.Query.filter_lbrack_betaAppReviewSubmission_period_betaReviewState_rbrack_PayloadPayload),
//    public let fieldsBuildsVersion: String?
//    
    //let data: [Components.Schemas.BuildsWithoutIncludesResponse]
    
//    init?(schema: Operations.builds_hyphen_get_collection.Input.Query) {
//        let betaReview = schema.fields_lbrack_betaAppReviewSubmissions_rbrack_.
//        self.preVersionId = preVersionId
//    }

    
    
//    enum customClientQuery {
//        case ios
//        case macOs
//        case buildEligible
//        case betaReview
//        case fieldsBuildsVersion
//    }
    
    /// Coding keys for custom JSON encoding/decoding.
//    enum CodingKeys: String, CodingKey {
//        case ios = "IOS"
//        case macOs = "MAC_OS"
//        case buildEligible = "APP_STORE_ELIGIBLE"
//        case waiting = "WAITING_FOR_REVIEW"
//        case inReview = "IN_REVIEW"
//        case rejected = "REJECTED"
//        case approved = "APPROVED"
//        case fieldsBuildsVersion = "version"
//    }
//}
// fields[builds] - uploadedDate, expirationDate, minOsVersion, computedMinMacOsVersion, processingState
//let filterValues: [Operations.builds_hyphen_get_collection.Input.Query.filter_lbrack_betaAppReviewSubmission_period_betaReviewState_rbrack_PayloadPayload] = [
//    .WAITING_FOR_REVIEW,
//    .IN_REVIEW
//]
//
//let query = Operations.builds_hyphen_get_collection.Input.Query(
//    filter_lbrack_betaAppReviewSubmission_period_betaReviewState_rbrack_: filterValues
//)
