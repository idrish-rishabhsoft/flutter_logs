package com.flutter.logs.plogs.flutter_logs

data class DeviceInfo(val osVersion: String, val appVersion: String, val deviceModel: String) {
    override fun toString(): String {
        return "\nDevice Model: $deviceModel \nOSVersion: $osVersion \nApp Version: $appVersion"
    }
}
