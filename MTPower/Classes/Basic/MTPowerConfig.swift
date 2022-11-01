//
//  MTPowerConfig.swift
//  MTPower
//
//  Created by PanGu on 2022/10/18.
//

import Foundation


public class MTPowerConfig{
    public static let `default` = MTPowerConfig()
    
    public var isLogEnabled = false
    
    public var nav_bg_color = UIColor.white
    public var nav_bg_alpha: CGFloat = 1
    public var nav_back_image: UIImage?
    public var nav_title_color: UIColor = .black
    public var nav_title_font = UIFont.systemFont(ofSize: 18)
    /// 左右内容间距
    public var nav_content_hrz_inset: CGFloat = 10
    /// 按钮间距
    public var nav_item_space: CGFloat = 10
    /// 按钮颜色
    public var nav_item_color: UIColor = .black
    public var nav_item_font = UIFont.systemFont(ofSize: 17)
    /// 底部黑线颜色
    public var nav_shadow_line_color = UIColor.lightGray
    public var nav_height_notX_height: CGFloat = 64

    /// 旋转方向
    public var allowedOrientation: UIInterfaceOrientationMask = .portrait

    public func rotateHrz(){
        MTPowerConfig.default.allowedOrientation = .landscapeRight
        UIDevice.current.setValue(3, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }
    public func rotateVtc(){
        MTPowerConfig.default.allowedOrientation = .portrait
        UIDevice.current.setValue(1, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }
    
    public func rotateToggle(){
        if MTPowerConfig.default.allowedOrientation == .portrait{
            rotateHrz()
        }else{
            rotateVtc()
        }
    }
    
    /// deivice keychain access service key
    @MTAssignOnce<String> public static var deviceKeychainKey: String?
    

}
