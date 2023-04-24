//
//  Controller_Ext.swift
//  MTPower
//
//  Created by PanGu on 2022/10/19.
//

import Foundation
public func mt_keyWindow() -> UIWindow? {
    if #available(iOS 13, *) {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let window = scene.windows.first(where: { $0.isKeyWindow }) {
            return window
        }
    }
    return UIApplication.shared.delegate?.window ?? nil
}

public func mt_visibleViewController() -> UIViewController? {
    guard let win = mt_keyWindow(),
          let root = win.rootViewController
    else { return nil }

    return mt_viewController(from: root)
}

public func mt_viewController(from controller: UIViewController) -> UIViewController {
    if let nav = controller as? UINavigationController,
       let topVC = nav.viewControllers.last {
        return mt_viewController(from: topVC)
    }

    if let tab = controller as? UITabBarController,
       let selected = tab.selectedViewController {
        return mt_viewController(from: selected)
    }

    if let presentedVC = controller.presentedViewController {
        return mt_viewController(from: presentedVC)
    }

    return controller
}
