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
        var errorsPayload: Components.Schemas.ErrorResponse.errorsPayload = []
        let payload1 = Components.Schemas.ErrorResponse.errorsPayload.init(arrayLiteral: .init(status: "400", code: "BAD_REQUEST", title: "Invalid Input", detail: "The provided data failed validation"))
        let payload2 = Components.Schemas.ErrorResponse.errorsPayload.init(arrayLiteral: .init(status: "500", code: "INTERNAL_SERVER_ERROR", title: "Server Error", detail: "An unexpected error"))
        
        
        //let mock = MockAPIClient()
        var errorsArray: [Components.Schemas.ErrorResponse] = []
        let response1 = Components.Schemas.ErrorResponse(
            errors: Components.Schemas.ErrorResponse.errorsPayload.init(arrayLiteral: .init(status: "400", code: "BAD_REQUEST", title: "Invalid Input", detail: "The provided data failed validation"))
        )
//        switch mock.result {
//            case .badRequest:
//                response = Components.Schemas.ErrorResponse(
//                    errors: Components.Schemas.ErrorResponse.errorsPayload.init(arrayLiteral: .init(status: "400", code: "BAD_REQUEST", title: "Invalid Input", detail: "The provided data failed validation"))
//                )
//            case .forbidden:
//                response = Components.Schemas.ErrorResponse(
//                    errors: Components.Schemas.ErrorResponse.errorsPayload.init(arrayLiteral: .init(status: "403", code: "FORBIDDEN", title: "Access Denied", detail: "You do not have permission to access this resource"))
        //        )
        let response2 = Components.Schemas.ErrorResponse(
            errors: Components.Schemas.ErrorResponse.errorsPayload.init(arrayLiteral: .init(status: "500", code: "INTERNAL_SERVER_ERROR", title: "Server Error", detail: "An unexpected error"))
        )
        errorsPayload.append(payload1)
        errorsPayload.append(payload2)
        return errorsPayload
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
    
    static var appsResponseForFetchApps: Components.Schemas.AppsResponse {
        let response = Components.Schemas.AppsResponse(
            data: [app],
            links: Components.Schemas.PagedDocumentLinks(_self: "")
        )
        return response
    }
    
    static var errorResponseForFetchApps: Components.Schemas.ErrorResponse {
        let response = Components.Schemas.ErrorResponse(
            errors: Components.Schemas.ErrorResponse.errorsPayload()
        )
        return response
    }
}
