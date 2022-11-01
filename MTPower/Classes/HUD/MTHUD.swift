//
//  MTHUD.swift
//  MTPower
//
//  Created by PanGu on 2022/10/19.
//

import Foundation
import MBProgressHUD
public class MTHUD: MBProgressHUD{
    public static var backgroundColor = UIColor.black.withAlphaComponent(0.6)
    public static var hudColor = UIColor.white
    public static var labelFont = UIFont.systemFont(ofSize: 15)
    public static var labelColor = UIColor.white
    
    @discardableResult
    public static func show(onView superView: UIView? = nil,
                     text: String? = nil) -> MTHUD
    {
        let hud = MTHUD.__showHUD(to: superView)
        hud.label.text = text
        return hud
    }
    
    /// 显示文字
    @discardableResult
    public static func showText(_ text: String,
                                offset: CGPoint = .zero,
                                onView superView: UIView? = nil,
                                delay: Double = 2.0,
                                isExclusive: Bool = false) -> MTHUD
    {
        let hud = MTHUD.__showHUD(to: superView)
        hud.mode = .text
        hud.label.text = text
        hud.offset = offset
        hud.hide(animated: true, afterDelay: delay)
        hud.isUserInteractionEnabled = isExclusive
        return hud
    }
    
    @discardableResult
    public static func showProgressText(_ text: String,
                                        offset: CGPoint = .zero,
                                        onView superView: UIView? = nil) -> MTHUD
    {
        let hud = MTHUD.__showHUD(to: superView)
        hud.mode = .indeterminate
        hud.label.text = text
        hud.offset = offset
        return hud
    }
    
    /// 隐藏HUD
    public static func hide(onView superView: UIView? = nil) {
        var view = superView
        if view == nil { view = UIApplication.shared.keyWindow }
        if view == nil { return }
        MTHUD.hide(for: view!, animated: true)
    }
    
    /// 进度条HUD
    @discardableResult
    public static func showProgress(onView superView: UIView? = nil,
                                    text: String? = nil) -> MTHUD
    {
        let hud = MTHUD.__showHUD(to: superView)
        hud.mode = .annularDeterminate
        hud.label.text = text
        return hud
    }

    /// 自定义view
    @discardableResult
    public static func showCustomView(_ customView: UIView,
                                      onView superView: UIView? = nil) -> MTHUD
    {
        let hud = __showHUD(to: superView)
        hud.mode = .customView
        hud.customView = customView
        hud.bezelView.color = .clear
        return hud
    }
}

extension MTHUD{
    @discardableResult
    private static func __showHUD(to superView: UIView?) -> MTHUD {
        var view = superView
        if view == nil { view = UIApplication.shared.keyWindow }
        if view == nil { return MTHUD(frame: .zero) }

        let hud = MTHUD.showAdded(to: view!, animated: true)
        hud.removeFromSuperViewOnHide = true
        hud.bezelView.style = .solidColor
        hud.bezelView.color = MTHUD.backgroundColor
        hud.contentColor = MTHUD.hudColor
        hud.label.textColor = MTHUD.labelColor
        hud.label.font = MTHUD.labelFont
        hud.label.numberOfLines = 0
        return hud
    }
}
