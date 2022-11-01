//
//  MTNotification.swift
//  MTPower
//
//  Created by PanGu on 2022/10/18.
//

import Foundation

public protocol MTNotiProtocol {
    var name: String { get }
}

public func mt_noti(post noti: MTNotiProtocol,
                    userInfo: [AnyHashable: Any]? = nil) {
    NotificationCenter.default.post(name: .init(noti.name), object: nil, userInfo: userInfo)
}

public func mt_noti(observer: Any, selector: Selector, noti: MTNotiProtocol) {
    NotificationCenter.default.addObserver(observer, selector: selector, name: .init(noti.name), object: nil)
}

public func mt_noti(remove observer: Any) {
    NotificationCenter.default.removeObserver(observer)
}
