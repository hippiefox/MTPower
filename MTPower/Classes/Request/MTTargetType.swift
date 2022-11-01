//
//  MTTargetType.swift
//  MTPower
//
//  Created by PanGu on 2022/10/19.
//

import Foundation
import Moya

public enum MTHUDType{
    case progress
    case progressText(String)
}

public enum MTCacheType{
    case onlyRequest
    case requestCache
    case onlyReadCache
}
 
public protocol MTTargetType: TargetType {
    var cacheType: MTCacheType { get }
    var hudType: MTHUDType{  get}
    var needShowHUD: Bool { get }
    var timeoutInterval: TimeInterval { get }
    var params: [String: Any] { get }
    var isRespEncrypted: Bool{  get}
}
