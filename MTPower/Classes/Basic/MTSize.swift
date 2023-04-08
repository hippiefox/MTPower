//
//  MTSize.swift
//  MTPower
//
//

import Foundation

public let MT_SCREEN_WIDTH = UIScreen.main.bounds.width
public let MT_SCREEN_HEIGHT = UIScreen.main.bounds.height
public var MT_SCREEN_MIN_SIZE: CGFloat{ min(MT_SCREEN_WIDTH, MT_SCREEN_HEIGHT)}

public func MT_Baseline(_ a: CGFloat)-> CGFloat{
    a * (MT_SCREEN_WIDTH / 375)
}

public let MT_SafeAreaInsets = UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero

public let MT_NAV_HEIGHT_NOTX: CGFloat = 64
public let MT_NAV_HEIGHT: CGFloat = MT_SafeAreaInsets.top > 0 ? MT_SafeAreaInsets.top + 44 : MT_NAV_HEIGHT_NOTX
