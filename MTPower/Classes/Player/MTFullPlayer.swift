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

    override open func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    override open func configurePlayer() {
        if let playItem = playItem {
            fullControlsView.title = playItem.filename
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
            fullControlsView.loadingTips = playItem.loadingTips
            fullControlsView.bufferItem = playItem.bufferItem
        }
        super.configurePlayer()
    }

    override open func playerPlaybackIsPreparedToPlay(_ noti: NSNotification) {
        super.playerPlaybackIsPreparedToPlay(noti)
        fullControlsView.isReadyToPlay = true
    }

    override open func playerPlaybackDidFinish(_ noti: NSNotification) {
        fullControlsView.isReadyToPlay = false
        super.playerPlaybackDidFinish(noti)
    }

    override open func handleControlsOption(_ opt: MTBasicPlayerControls.Option) {
        switch opt {
        case .play:
            fullControlsView.bufferManager.isStopForAWhile = false
        case .pause:
            // 用户手动点击了暂停
            fullControlsView.bufferManager.isStopForAWhile = true
        case .rate:
            fullControlsView.startTrial()
            return
        default: break
        }
        super.handleControlsOption(opt)
    }

    open func handleBufferOption(_ opt: MTFullPlayerControls.BufferOption) {
        switch opt {
        case .pause: super.handleControlsOption(.pause)
        case .play: super.handleControlsOption(.play)
        case .bufferPeriodEnds:
            fullControlsView.bufferManager.isStopForAWhile = true
        case let .slideLimit(targetTime):
            super.handleControlsOption(.pause)
            fullControlsView.bufferManager.isStopForAWhile = true
            bdPlayer.currentPlaybackTime = .init(targetTime)
        case .trialPeriodEnd:
            super.handleControlsOption(.pause)
            fullControlsView.bufferManager.reset(bufferItem: nil)
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

// MARK: - - Configure UI

extension MTFullPlayer {
    private func configureUI() {
        basicControlsView.removeFromSuperview()
        basicControlsView = fullControlsView
        view.addSubview(basicControlsView)
        basicControlsView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
