//
//  MockClient.swift
//
//
//  Created by Mykola Vasyk on 22.04.2024.
//

import Foundation
import OpenAPIRuntime
@testable import AppStoreConnectClient

struct MockClient: APIProtocol {
    var result: String?
    func apps_hyphen_appStoreVersions_hyphen_get_to_many_related(
        _ input: Operations.apps_hyphen_appStoreVersions_hyphen_get_to_many_related.Input
    ) async throws -> Operations.apps_hyphen_appStoreVersions_hyphen_get_to_many_related.Output {
        switch result {
        case "ok":
            return .ok(.init(body: .json(MockObjects.appStoreVersionsResponse)))
        case "badRequest":
            return .badRequest(.init(body: .json(MockObjects.errorResponse)))
        case "forbidden":
            return .forbidden(.init(body: .json(MockObjects.errorResponse)))
        case "notFound":
            return .notFound(.init(body: .json(MockObjects.errorResponse)))
        case "unauthorized":
            return .unauthorized(.init(body: .json(MockObjects.errorResponse)))
        case "undocumented":
            return .undocumented(statusCode: 501, UndocumentedPayload())
        case .none:
            return .undocumented(statusCode: 501, UndocumentedPayload())
        case .some(_):
            return .undocumented(statusCode: 501, UndocumentedPayload())
        }
    }
    
    func apps_hyphen_get_collection(
        _ input: Operations.apps_hyphen_get_collection.Input
    ) async throws -> Operations.apps_hyphen_get_collection.Output {
        switch result {
        case "ok":
            return .ok(.init(body: .json(MockObjects.appsResponse)))
        case "badRequest":
            return .badRequest(.init(body: .json(MockObjects.errorResponse)))
        case "forbidden":
            return .forbidden(.init(body: .json(MockObjects.errorResponse)))
        case "unauthorized":
            return .unauthorized(.init(body: .json(MockObjects.errorResponse)))
        case "undocumented":
            return .undocumented(statusCode: 501, UndocumentedPayload())
        case .none:
            return .undocumented(statusCode: 501, UndocumentedPayload())
        case .some(_):
            return .undocumented(statusCode: 501, UndocumentedPayload())
        }
    }
}
