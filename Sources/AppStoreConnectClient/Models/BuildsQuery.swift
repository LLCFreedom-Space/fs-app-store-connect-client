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
//  BuildsQuery.swift
//
//
//  Created by Mykola Vasyk on 12.06.2024.
//

import Foundation

/// A structure representing a query for builds with specified sort and fields parameters.
public struct BuildsQuery {
    /// The sort payload for the query.
    public let sort: [Sort]
    /// The fields payload for the query.
    public let fields: [Fields]
    
    /// Initializes a new instance of the BuildsQuery structure.
    /// - Parameters:
    ///   - sort: An array of Sort objects representing the sort parameters for the query. Default value is an empty array.
    ///   - fields: An array of Fields objects representing the fields parameters for the query. Default value is an empty array.
    public init(sort: [Sort] = [], fields: [Fields] = []) {
        self.sort = sort
        self.fields = fields
    }
    
    /// Converts the Sort enum array to the appropriate payload type used in the query.
    /// - Parameter from: The Sort enum value to convert.
    /// - Returns: The converted sort payload.
    func convert(from sorts: [Sort]) -> [Operations.builds_hyphen_get_collection.Input.Query.sortPayloadPayload] {
        return sorts.compactMap { sort in
            return Operations.builds_hyphen_get_collection.Input.Query.sortPayloadPayload(rawValue: sort.rawValue)
        }
    }
    
    /// Converts the Fields enum array to the appropriate payload type used in the query.
    /// - Parameter from: The array of Fields enum values to convert.
    /// - Returns: An array of converted field payloads.
    func convert(from fields: [Fields]) -> [Operations.builds_hyphen_get_collection.Input.Query.fields_lbrack_builds_rbrack_PayloadPayload] {
        return fields.compactMap { field in
            return Operations.builds_hyphen_get_collection.Input.Query.fields_lbrack_builds_rbrack_PayloadPayload(rawValue: field.rawValue)
        }
    }
    
    /// An enumeration representing the possible sort options for the query.
    public enum Sort: String {
        case preReleaseVersion
        case hyphenPreReleaseVersion = "-preReleaseVersion"
        case uploadedDate
        case hyphenUploadedDate = "-uploadedDate"
        case version
        case hyphenVersion = "-version"
    }
    
    /// An enumeration representing the possible fields that can be included in the query.
    public enum Fields: String {
        case app
        case appEncryptionDeclaration
        case appStoreVersion
        case betaAppReviewSubmission
        case betaBuildLocalizations
        case betaGroups
        case buildAudienceType
        case buildBetaDetail
        case buildBundles
        case computedMinMacOsVersion
        case diagnosticSignatures
        case expirationDate
        case expired
        case iconAssetToken
        case icons
        case individualTesters
        case lsMinimumSystemVersion
        case minOsVersion
        case perfPowerMetrics
        case preReleaseVersion
        case processingState
        case uploadedDate
        case usesNonExemptEncryption
        case version
    }
}
