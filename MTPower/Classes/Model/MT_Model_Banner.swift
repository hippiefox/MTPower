//
//  MT_Model_Banner.swift
//  MTPower
//
//  Created by pulei yu on 2023/4/19.
//

import Foundation
 
public struct MT_Model_Banner {
    public let title: String
    public let text: String
    public let url: String
    public let coverUrl: String
    public let date: String
}


public struct MT_Model_Banner_Version {
    public let code: Int
    public let version: String
    public let url: String
    public let isForced: Bool
    public let notes: String

    static func versionCode(from version: String) -> Int {
        var arr = version.components(separatedBy: ".")
        let bitGap = 3 - arr.count
        for _ in 0 ..< bitGap {
            arr.append("0")
        }
        var value = 0
        for i in 0 ..< arr.count {
            let weight = pow(100, Float(arr.count - 1 - i))
            value += Int(weight) * (Int(arr[i]) ?? 0)
        }
        return value
    }
}
