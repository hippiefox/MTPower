//
//  MTViewController.swift
//  MTPower
//
//  Created by PanGu on 2022/10/23.
//

import Foundation

open class MTViewController: UIViewController {
    open var mt_navigationBar: MTNavigationBar?

    open lazy var naviBackButton: MTButton = {
        let button = MTButton()
        button.frame.size = .init(width: MT_Baseline(40), height: MT_Baseline(40))
        button.iconNormal = MTPowerConfig.default.nav_back_image
        button.iconSize = .init(width: 26, height: 26)
        button.addTarget(self, action: #selector(actionBack), for: .touchUpInside)
        return button
    }()

    override open func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = true
        initNavigationBar()
    }

    open func customLeftNavigationItem(_ target: Any?, selector: Selector) -> MTBarButtonItem? {
        var leftItem: MTBarButtonItem?
        if navigationController != nil {
            leftItem = MTBarButtonItem(customView: naviBackButton)
        }
        return leftItem
    }

    @objc open func actionBack() {
        navigationController?.popViewController(animated: true)
    }

    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let mt_navigationBar = mt_navigationBar {
            mt_navigationBar.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: MT_NAV_HEIGHT)
            view.bringSubview(toFront: mt_navigationBar)
        }
    }

    private func initNavigationBar() {
        if let navigationController = navigationController {
            mt_navigationBar = MTNavigationBar()
            mt_navigationBar?.weakController = self
            view.addSubview(mt_navigationBar!)
            if navigationController.viewControllers.count > 1 {
                mt_navigationBar?.leftItem = customLeftNavigationItem(self, selector: #selector(actionBack))
            }
        }
    }

    deinit {
        MTLog("------>deinit", self.classForCoder.description())
    }
}
