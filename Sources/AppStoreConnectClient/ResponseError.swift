//
//  ResponseError.swift
//
//
//  Created by Mykola Vasyk on 03.05.2024.
//

import Foundation

public struct ResponseError: Error, Equatable {
    public var code: String
    public var status: String
    public var title: String
    public var detail: String
    
    public init(
        code: String, status: String, title: String, detail: String
    ) {
        self.code = code
        self.status = status
        self.title = title
        self.detail = detail
    }
    
    init?(
        schema: Components.Schemas.ErrorResponse.errorsPayloadPayload
    ) {
        self.code = schema.code
        self.status = schema.status
        self.title = schema.title
        self.detail = schema.detail
    }
}
