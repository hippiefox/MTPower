//
//  MTDevice.swift
//  MTPower
//
//

import Foundation
import KeychainAccess
public struct MTDevice {
    /// service key of `deivice id` in keychain access
    @MTAssignOnce<String> public static var deviceKeychainKey: String?
    
    
    public static let appName: String = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? ""
    public static let bundleId = Bundle.main.bundleIdentifier ?? ""
    public static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    public static let deviceName = UIDevice.current.name
    public static let systemName = UIDevice.current.systemName
    public static let systemVersion = UIDevice.current.systemVersion
    public static let deviceModel = UIDevice.current.model
    public static let localLanguage = Locale.preferredLanguages[0]
    public static var language: String {
        return Locale.preferredLanguages[0].components(separatedBy: "-").first!
    }

    public static var uniqueID: String {
        let service = deviceKeychainKey ?? MTDevice.bundleId
        let key = deviceKeychainKey ?? MTDevice.bundleId
        let kcService = Keychain(service: service)

        if let deviceId = try? kcService.get(key){
            return deviceId
        }

        let uuidRef = CFUUIDCreate(kCFAllocatorDefault)
        let uuidString = CFUUIDCreateString(kCFAllocatorDefault, uuidRef)
        let __uuidStr = uuidString as? String ?? ""
        do {
            try kcService.set(__uuidStr, key: key)
            return __uuidStr
        } catch {
            return ""
        }
    }
}
