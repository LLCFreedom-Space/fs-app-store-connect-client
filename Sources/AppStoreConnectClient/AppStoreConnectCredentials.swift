//
//  AppStoreConnectCredentials.swift
//  
//
//  Created by Mykola Vasyk on 22.04.2024.
//

import Foundation

public struct AppStoreConnectCredentials: Sendable {
    let issuerId: String
    let privateKeyId: String
    let privateKey: String
}
