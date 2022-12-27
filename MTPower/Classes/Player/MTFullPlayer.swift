//
//  MTFullPlayer.swift
//  MTPower
//
//  Created by PanGu on 2022/10/30.
/*
    player:buffer control, slideLimit, trial control
 */

import Foundation
import SJMediaCacheServer

open class MTFullPlayer: MTPlayer {
    public var playItem: MTFullPlayerItem!

    public lazy var fullControlsView: MTFullPlayerControls = {
        let view = MTFullPlayerControls()
        view.optionBlock = { [weak self] opt in
            self?.handleControlsOption(opt)
        }

        view.bufferOption = { [weak self] opt in
            self?.handleBufferOption(opt)
        }
        return view
    }()
    
    open override func setupPlayControls() {
        __playControl = fullControlsView
    }

    override open func configurePlayer() {
        if let playItem = playItem {
            (__playControl as? MTFullPlayerControls)?.title = playItem.filename
            
            if playItem.isLocalPath {
                fileURL = URL(fileURLWithPath: playItem.fileUrl)
            } else {
                fileURL = URL(string: playItem.fileUrl)
                /// 非本地文件，尝试解密
                if playItem.isEncryted,
                    let url = SJMediaCacheServer.shared().playbackURL(with: fileURL)
                {
                     SJMediaCacheServer.shared().isEnabledConsoleLog = false
                     SJMediaCacheServer.shared().logLevel = .debug
                     SJMediaCacheServer.shared().logOptions = .proxyTask
                     SJMediaCacheServer.shared().writeDataEncoder = { _, _, data in
                         let res = NSData.mtp_xor(data)
                         return res
                     }
                     fileURL = url
                }
            }
            
            headerJSONStr = playItem.headerJSONStr
            (__playControl as? MTFullPlayerControls)?.loadingTips = playItem.loadingTips
            (__playControl as? MTFullPlayerControls)?.bufferItem = playItem.bufferItem
        }
        super.configurePlayer()
    }

    override open func playerPlaybackIsPreparedToPlay(_ noti: NSNotification) {
        super.playerPlaybackIsPreparedToPlay(noti)
        (__playControl as? MTFullPlayerControls)?.isReadyToPlay = true
        
    }

    override open func playerPlaybackDidFinish(_ noti: NSNotification) {
        (__playControl as? MTFullPlayerControls)?.isReadyToPlay = false
        super.playerPlaybackDidFinish(noti)
    }

    override open func handleControlsOption(_ opt: MTBasicPlayerControls.Option) {
        switch opt {
        case .play:
            (__playControl as? MTFullPlayerControls)?.bufferManager.isStopForAWhile = false
        case .pause:
            // 用户手动点击了暂停
            (__playControl as? MTFullPlayerControls)?.bufferManager.isStopForAWhile = true
        default: break
        }
        super.handleControlsOption(opt)
    }

    open func handleBufferOption(_ opt: MTFullPlayerControls.BufferOption) {
        switch opt {
        case .pause: super.handleControlsOption(.pause)
        case .play: super.handleControlsOption(.play)
        case .bufferPeriodEnds:
            (__playControl as? MTFullPlayerControls)?.bufferManager.isStopForAWhile = true
        case let .slideLimit(targetTime):
            super.handleControlsOption(.pause)
            (__playControl as? MTFullPlayerControls)?.bufferManager.isStopForAWhile = true
            bdPlayer.currentPlaybackTime = .init(targetTime)
        case .trialPeriodEnd:
            super.handleControlsOption(.pause)
            (__playControl as? MTFullPlayerControls)?.bufferManager.reset(bufferItem: nil)
        }
    }
    
    open override func actionClose() {
        clearSJCache()
        super.actionClose()
    }
    open func clearSJCache(){
        guard let playItem = self.playItem,
              playItem.isEncryted
        else{   return}
        
        SJMediaCacheServer.shared().removeCache(for: self.fileURL)
    }
}
