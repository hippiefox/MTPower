//
//  MTNavigationController.swift
//  MTPower
//
//  Created by PanGu on 2022/10/23.
//

import Foundation


open class MTProtoNavigationController: UINavigationController{
    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if viewControllers.count >= 1{
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }
}
