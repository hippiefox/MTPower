//
//  Alert_Ext.swift
//  MTPower
//
//  Created by PanGu on 2022/10/18.
//

import Foundation

public extension UIAlertController {
    static func mt_show(from controller: UIViewController,
                        title: String?,
                        msg: String?,
                        cancel: String?,
                        cancelBlock: (() -> Void)?,
                        cancelColor: UIColor? = nil,
                        confirm: String?,
                        confirmBlock: (() -> Void)?,
                        confirmColor: UIColor? = nil) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)

        if let cancel = cancel {
            let action = UIAlertAction(title: cancel, style: .cancel) { _ in
                cancelBlock?()
            }
            if let color = cancelColor {
                action.setValue(color, forKey: "_titleTextColor")
            }
            alert.addAction(action)
        }

        if let confirm = confirm {
            let action = UIAlertAction(title: confirm, style: .default) { _ in
                confirmBlock?()
            }
            if let color = confirmColor {
                action.setValue(color, forKey: "_titleTextColor")
            }
            alert.addAction(action)
        }

        controller.present(alert, animated: true)
    }
}
