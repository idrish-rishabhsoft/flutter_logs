//
//  DeviceInfo.swift
//  flutter_logs
//
//  Created by Idrish Sorathiya on 12/01/24.
//

import Foundation

public struct DeviceInfo: CustomStringConvertible {
    let osVersion: String
    let appVersion: String
    let deviceModel: String

    public var description: String {
        return "\nDevice Model: \(deviceModel) \nOS Version: \(osVersion) \nApp Version: \(appVersion)"
    }
}
