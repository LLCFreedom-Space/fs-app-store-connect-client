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
//  MockObjects.swift
//
//
//  Created by Mykola Vasyk on 22.04.2024.
//

import Foundation
import OpenAPIRuntime
@testable import AppStoreConnectClient

enum MockObjects {
    static var errorBadRequest: Components.Schemas.ErrorResponse {
        return (
            .init(
                errors: Components.Schemas.ErrorResponse.errorsPayload.init(
                    arrayLiteral: .init(
                        status: "400",
                        code: "Foo",
                        title: "Bar",
                        detail: "Baz"
                    )
                )
            )
        )
    }
    
    static var errorForbidden: Components.Schemas.ErrorResponse {
        return (
            .init(
                errors: Components.Schemas.ErrorResponse.errorsPayload.init(
                    arrayLiteral: .init(
                        status: "403",
                        code: "Foo",
                        title: "Bar",
                        detail: "Baz"
                    )
                )
            )
        )
    }
    
    static var errorNotFound: Components.Schemas.ErrorResponse {
        return (
            .init(
                errors: Components.Schemas.ErrorResponse.errorsPayload.init(
                    arrayLiteral: .init(
                        status: "404",
                        code: "Foo",
                        title: "Bar",
                        detail: "Baz"
                    )
                )
            )
        )
    }
    
    static var errorUnauthorized: Components.Schemas.ErrorResponse {
        return (
            .init(
                errors: Components.Schemas.ErrorResponse.errorsPayload.init(
                    arrayLiteral: .init(
                        status: "401",
                        code: "Foo",
                        title: "Bar",
                        detail: "Baz"
                    )
                )
            )
        )
    }
    
    static var okBuild: Components.Schemas.Build {
        let dateFormatter = DateFormatter()
        let mockData = dateFormatter.date(from: "2011-11-11 11:11:11 +0000")
        let response = Components.Schemas.Build(
            _type: .preReleaseVersions,
            id: "FooBarBazId",
            attributes: .init(
                version: "Foo",
                platform: .IOS,
                uploadedDate: mockData,
                expirationDate: mockData,
                expired: true,
                minOsVersion: "Foo",
                lsMinimumSystemVersion: "FooMinSysVer",
                computedMinMacOsVersion: "BarCompMinMacOsVer",
                iconAssetToken: .none,
                processingState: .PROCESSING,
                buildAudienceType: .APP_STORE_ELIGIBLE,
                usesNonExemptEncryption: true),
            relationships: .none,
            links: .none
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
                versionString: "Foo.Bar.Baz",
                appStoreState: .ACCEPTED
            )
        )
        return response
    }
    
    static var okPrereleaseVersion: Components.Schemas.PrereleaseVersionWithoutIncludesResponse {
        let dateFormatter = DateFormatter()
        let mockData = dateFormatter.date(from: "2011-11-11 11:11:11 +0000")
        let response = Components.Schemas.PrereleaseVersionWithoutIncludesResponse(
            data: .init(
                _type: .preReleaseVersions,
                id: "FooBarId",
                attributes: .init(
                    version: "Foo",
                    platform: .IOS,
                    uploadedDate: mockData,
                    expirationDate: mockData,
                    expired: true,
                    minOsVersion: "FooMinOs",
                    lsMinimumSystemVersion: "BarMinSysVer",
                    computedMinMacOsVersion: "BazCompMinMacOsVer",
                    iconAssetToken: .none,
                    processingState: .PROCESSING,
                    buildAudienceType: .APP_STORE_ELIGIBLE,
                    usesNonExemptEncryption: false
                ),
                relationships: .none,
                links: .init(_self: "FooBarBazLink1")
            ),
            links: .init(_self: "FooBarBazLink2")
        )
        return response
    }
    
    static var schema: Components.Schemas.Build {
        let dateFormatter = DateFormatter()
        let mockData = dateFormatter.date(from: "2011-11-11 11:11:11 +0000")
        let schema = Components.Schemas.Build(
            _type: .builds,
            id: "FooBarBazId",
            attributes: .init(
                version: "Foo",
                uploadedDate: mockData,
                minOsVersion: "Foo"
            ),
            relationships: .none,
            links: .none
        )
        return schema
    }
}
