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
//  MockAPIClient.swift
//
//
//  Created by Mykola Vasyk on 22.04.2024.
//

import Foundation
import OpenAPIRuntime
@testable import AppStoreConnectClient

struct MockAPIClient: APIProtocol {
    var result: Result?
    let statusCode = 501
    
    func apps_hyphen_get_collection(
        _ input: Operations.apps_hyphen_get_collection.Input
    ) async throws -> Operations.apps_hyphen_get_collection.Output {
        switch result {
        case .ok:
            return .ok(.init(body: .json(MockObjects.appsResponse)))
        case .badRequest:
            return .badRequest(.init(body: .json(MockObjects.badRequest)))
        case .forbidden:
            return .forbidden(.init(body: .json(MockObjects.forbidden)))
        case .unauthorized:
            return .unauthorized(.init(body: .json(MockObjects.unauthorized)))
        case .undocumented:
            return .undocumented(statusCode: statusCode, UndocumentedPayload())
        case .none:
            return .undocumented(statusCode: statusCode, UndocumentedPayload())
        case .some:
            return .undocumented(statusCode: statusCode, UndocumentedPayload())
        }
    }
    
    func apps_hyphen_appStoreVersions_hyphen_get_to_many_related(
        _ input: Operations.apps_hyphen_appStoreVersions_hyphen_get_to_many_related.Input
    ) async throws -> Operations.apps_hyphen_appStoreVersions_hyphen_get_to_many_related.Output {
        switch result {
        case .ok:
            return .ok(.init(body: .json(MockObjects.appStoreVersionsResponse)))
        case .badRequest:
            return .badRequest(.init(body: .json(MockObjects.badRequest)))
        case .forbidden:
            return .forbidden(.init(body: .json(MockObjects.forbidden)))
        case .notFound:
            return .notFound(.init(body: .json(MockObjects.notFound)))
        case .unauthorized:
            return .unauthorized(.init(body: .json(MockObjects.unauthorized)))
        case .undocumented:
            return .undocumented(statusCode: statusCode, UndocumentedPayload())
        case .none:
            return .undocumented(statusCode: statusCode, UndocumentedPayload())
        case .some:
            return .undocumented(statusCode: statusCode, UndocumentedPayload())
        }
    }
    
    func builds_hyphen_get_collection(
        _ input: Operations.builds_hyphen_get_collection.Input
    ) async throws -> Operations.builds_hyphen_get_collection.Output {
        switch result {
        case .ok:
            return .ok(.init(body: .json(.init(data: [MockObjects.buildOkResponse], links: .init(_self: "https://mockLink")))))
        case .badRequest:
            return .badRequest(.init(body: .json(MockObjects.badRequest)))
        case .forbidden:
            return .forbidden(.init(body: .json(MockObjects.forbidden)))
        case .unauthorized:
            return .unauthorized(.init(body: .json(MockObjects.unauthorized)))
        case .none:
            return .undocumented(statusCode: statusCode, UndocumentedPayload())
        case .some:
            return .undocumented(statusCode: statusCode, UndocumentedPayload())
        }
    }
    
    func builds_hyphen_preReleaseVersion_hyphen_get_to_one_related(
        _ input: Operations.builds_hyphen_preReleaseVersion_hyphen_get_to_one_related.Input
    ) async throws -> Operations.builds_hyphen_preReleaseVersion_hyphen_get_to_one_related.Output {
        switch result {
        case .ok:
            return .ok(.init(body: .json(MockObjects.prereleaseVersion)))
        case .badRequest:
            return .badRequest(.init(body: .json(MockObjects.badRequest)))
        case .forbidden:
            return .forbidden(.init(body: .json(MockObjects.forbidden)))
        case .unauthorized:
            return .unauthorized(.init(body: .json(MockObjects.unauthorized)))
        case .notFound:
            return .notFound(.init(body: .json(MockObjects.notFound)))
        case .none:
            return .undocumented(statusCode: statusCode, UndocumentedPayload())
        case .some:
            return .undocumented(statusCode: statusCode, UndocumentedPayload())
        }
    }
    
    enum Result {
        case ok
        case badRequest
        case forbidden
        case notFound
        case unauthorized
        case undocumented
    }
}
