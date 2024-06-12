//
//  PublicFieldsPayload.swift
//  
//
//  Created by Mykola Vasyk on 11.06.2024.
//

import Foundation

/// Represents a wrapper for fields payload used in the builds collection query.
public struct PublicFieldsPayload {
    /// The internal fields payload used in the builds collection query.
    let internalPayload: Operations.builds_hyphen_get_collection.Input.Query.fields_lbrack_builds_rbrack_Payload
    
    /// Initializes a `PublicFieldsPayload` with the provided internal fields payload.
    /// - Parameter schema: The internal fields payload.
    init(schema:
         Operations.builds_hyphen_get_collection.Input.Query.fields_lbrack_builds_rbrack_Payload
    ) {
        self.internalPayload = schema
    }
    
    /// Creates a `PublicFieldsPayload` for version, uploaded date, and minimum OS version fields.
    /// - Returns: An instance of `PublicFieldsPayload` configured for these fields.
    public static func defaultFields() -> PublicFieldsPayload {
        return PublicFieldsPayload(schema: .init([.version, .uploadedDate, .minOsVersion]))
    }
}
