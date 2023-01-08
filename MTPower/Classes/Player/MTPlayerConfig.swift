//
//  MTPlayerConfig.swift
//  MTPower
//
//  Created by PanGu on 2022/10/26.
//

import Foundation
import BDCloudMediaPlayer

public struct MTPlayerConfig{
    /// 百度播放器的id key
    @MTAssignOnce<String> public static var bdKey: String?
    
    /// 初始化player
    public static func setup(){
        assert(bdKey != nil)
        
        BDCloudMediaPlayerAuth.sharedInstance().authenticateLicenseID(bdKey!) { error in
            if let _ = error{
                MTLog("------>认证失败\(error!.localizedDescription)")
            }else{
                MTLog("------>播放器认证success")
            }
        }
    }
    
    
    //MARK: - (UI Elements)
    /// 播放器
    public static var playerItemSize: CGSize = .init(width: MT_Baseline(40), height: MT_Baseline(40))
    public static var playerItemIconSize: CGSize = .init(width: MT_Baseline(24), height: MT_Baseline(24))
    //MARK: (colors)
    public static var trackColor: UIColor = .gray
    public static var progressColor: UIColor = .white.withAlphaComponent(0.8)
    public static var tryingColor = UIColor.yellow
    //MARK: (images)
    public static var close: UIImage?
    public static var back: UIImage?
    public static var pause: UIImage?
    public static var play: UIImage?
    public static var slide: UIImage?
    public static var rotate: UIImage?
    public static var lock: UIImage?
    public static var unlock: UIImage?
    public static var download: UIImage?
    public static var scale: UIImage?
    public static var softHardDecode: UIImage?
    public static var volume: UIImage?
    public static var brightness: UIImage?
    public static var accelerate: UIImage?
    //MARK: (titles)
    public static var tryingTips: String?
    public static var tryingEndTips: String?
    public static var lockString: String?
    public static var unlockString: String?
    public static var accelerate3String: String?
    public static var softHardString: String?
    public static var scaleString: String?
    public static var softString: String? = "软解"
    public static var hardString: String? = "硬解"
    public static var scaleDefaultString: String? = "默认"
    public static var scaleStretchString: String? = "拉伸"
    public static var scaleFillString: String? = "填充"
    
    /// 播放器滑动手势的时长区域
    public static var playerSlideDuration: Float = 5 * 60
    public static var __defaultPlayerSlideDuration: Float = 5 * 60
    /// 自动隐藏controls的倒计时长
    public static var playerAutoHideItemsDuration: TimeInterval = 3
    
    public static var playerControlsPauseBackgroundColor: UIColor = UIColor.black.withAlphaComponent(0.2)
}

//MARK: Player Option
public extension MTPlayerConfig{
    enum SoftHardDecode: CaseIterable{
        case soft
        case hard
    }
    
    enum Rate: Float, CaseIterable{
        case r_0_75 = 0.75
        case r_1_0 = 1.0
        case r_1_25 = 1.25
        case r_1_5 = 1.5
        case r_1_75 = 1.75
        case r_2_0 = 2.0
        case r_3_0 = 3.0
    }
    
    enum Scale: CaseIterable{
        case `default`
        case fill
        case stretch
    }
}
