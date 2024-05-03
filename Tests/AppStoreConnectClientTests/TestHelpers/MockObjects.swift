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
}
