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
                        detail: "Foo Bar"
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
                        detail: "Foo Bar"
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
                        detail: "Foo Bar"
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
                        detail: "Foo Bar"
                    )
                )
            )
        )
    }
    
    static var ok: Components.Schemas.BuildsResponse {
        let response = Components.Schemas.BuildsResponse(
            data: .init(
                arrayLiteral: .init(
                    _type: .builds,
                    id: "FooBarBaz",
                    attributes: .none,
                    relationships: .none,
                    links: .none
                )
            ),
            included: .none,
            links: .init(_self: "FooBarBazLink"),
            meta: .none
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
        let response = Components.Schemas.PrereleaseVersionWithoutIncludesResponse(
            data: .init(
                _type: .builds,
                id: "FooBarBaz",
                attributes: .none,
                relationships: .none,
                links: .init(_self: "FooBarBazLink1")
            ),
            links: .init(_self: "FooBarBazLink2")
        )
        return response
    }
    
    static var prereleaseVersion: Components.Schemas.PrereleaseVersion {
        let response = Components.Schemas.PrereleaseVersion(
            _type: .preReleaseVersions,
            id: app.id,
            attributes: Components.Schemas.PrereleaseVersion.attributesPayload?(
                Components.Schemas.PrereleaseVersion.attributesPayload(
                    version: "Foo.Bar.Baz",
                    platform: .IOS
                )
            ),
            relationships: .none,
            links: .none
        )
        return response
    }
}
