//
//  MTFullPlayerItem.swift
//  MTPower
//
//  Created by PanGu on 2022/10/30.
//

import Foundation
/*
 - 播放器的播放项
 */
public class MTFullPlayerItem {
    public var filename: String?
    public var fileId: String!
    public var fileUrl: String!
    /// "{key:value,key1:value1}"
    public var headerJSONStr: String?
    public var isEncryted: Bool = false
    public var loadingTips: [String] = []
    public var source: String?
    public var fileetag: String?
    public var fileidx: String?
    public var isLocalPath: Bool = false
    public var bufferItem: MTFullPlayerBufferItem?

    public init() {}
}
/*
 播放器缓冲控制项
 */
public class MTFullPlayerBufferItem {
    /*buffer*/
    /// 次数，buffer次数
    public var k_trigger_boot: Int = 0
    /// 豪秒数, 播放时长
    public var m_playing_pause: Int = 0
    /// 豪秒数，buffer时长
    public var n_waiting_play: Int = 0
    
    public var bufferTag: String = ""
    /*drag*/
    /// 拖拽比例
    public var dragable_ratio: Float = 0
    /// 豪秒数
    public var min_drag_duration: Int = 0
    
    public var dragTag: String = ""
    
    /*trial*/
    /// 豪秒数
    public var trial_duration: Int = 0

    public var _isBufferable: Bool{
        (k_trigger_boot > 0 && m_playing_pause > 0 && n_waiting_play > 0) && bufferTag.isEmpty == false
    }
    public var _isLimitDragable: Bool{
        dragTag.isEmpty == false && (min_drag_duration > 0 || dragable_ratio > 0)
    }

    public init() {}
}


public class MTFullPlayerBufferManager{
    /// 暂停所有的buffer行为，等待恢复...
    public var isStopForAWhile: Bool = false
    
    public var isBufferable = false
    public var isBuffering = false
    public var playedDuration: Int = 0
    public var pausedDuration: Int = 0
    public var bufferPeriodCount: Int = 0
    /*trial*/
    public var isTrying: Bool = false
    /// trial left second
    public var tryingLeft: Int = 0
    private(set) var __totalTryingSeconds: Int = 0
    
    public func reset(bufferItem: MTFullPlayerBufferItem?){
        isBufferable = false
        isBuffering = false
        playedDuration = 0
        pausedDuration = 0
        bufferPeriodCount = 0
        isStopForAWhile = false
        if let item = bufferItem{
            isBufferable = item._isBufferable
            __totalTryingSeconds = item.trial_duration / 1000
        }
    }
}
