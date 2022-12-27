//
//  MTPlayer.swift
//  MTPower
//
//  Created by PanGu on 2022/10/26.
//

import BDCloudMediaPlayer
import BDCloudMediaUtils
import Foundation

/*
    只负责播放以及播放器的状态监听
 */
open class MTProtoPlayer: UIViewController {
    public var fileURL: URL!
    /// 格式: "{key:value,key1:value1}"
    public var headerJSONStr: String?

    public var bdPlayer: BDCloudMediaPlayerController!
    
    public var __playControl: MTProtoPlayControls!


    override open func viewDidLoad() {
        super.viewDidLoad()
        setupPlayControls()
        addBDPlayerNoti()
        configureUI()
        configurePlayer()
    }
    
    open func setupPlayControls(){
        
    }

    open func configurePlayer() {
        assert(fileURL != nil, "player file url can't be nil")

        // remove current player
        if let _ = bdPlayer {
            bdPlayer.view.removeFromSuperview()
            bdPlayer = nil
        }
        bdPlayer = BDCloudMediaPlayerController(contentURL: fileURL)
        bdPlayer.shouldAutoplay = true
        // config player hearders
        if let headerJSONStr = headerJSONStr,
           headerJSONStr.isEmpty == false,
           let jsonData = headerJSONStr.data(using: .utf8),
           let jsonObj = try? JSONSerialization.jsonObject(with: jsonData),
           let jsonDic = jsonObj as? [String: Any],
           jsonDic.isEmpty == false {
            var __headerStr = ""
            jsonDic.keys.forEach({
                let v = jsonDic[$0]!
                __headerStr += "\($0):\(v)\r\n"
            })
            bdPlayer.setOptionValue(__headerStr, forKey: "headers", of: BDCloudMediaPlayerOptionCategory.format)
        }
        // max timeout 60s
        bdPlayer.setTimeoutInUs(60 * 1000000)
        bdPlayer.prepareToPlay()
        view.insertSubview(bdPlayer.view, at: 0)
        bdPlayer.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    deinit {
        MTLog("------>deinit",self.classForCoder.description())
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - - Configure UI

extension MTProtoPlayer {
    private func configureUI() {
        view.backgroundColor = .black
    }
}

// MARK: Noti

extension MTProtoPlayer {
    private func addBDPlayerNoti() {
        NotificationCenter.default.addObserver(self, selector: #selector(playerPlaybackIsPreparedToPlay), name: NSNotification.Name.BDCloudMediaPlayerPlaybackIsPreparedToPlay, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerLoadStateDidChange), name: NSNotification.Name.BDCloudMediaPlayerLoadStateDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerPlaybackStateDidChange), name:
            NSNotification.Name.BDCloudMediaPlayerPlaybackStateDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerPlaybackDidFinish), name:
            NSNotification.Name.BDCloudMediaPlayerPlaybackDidFinish, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerMetadata), name:
            NSNotification.Name.BDCloudMediaPlayerMetadata, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerBufferingStart), name:
            NSNotification.Name.BDCloudMediaPlayerBufferingStart, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerBufferingUpdate), name:
            NSNotification.Name.BDCloudMediaPlayerBufferingUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerBufferingEnd), name:
            NSNotification.Name.BDCloudMediaPlayerBufferingEnd, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerHttpConnectEnd), name:
            NSNotification.Name.BDCloudMediaPlayerHttpConnectEnd, object: nil)
    }

    /// 播放状态更新
    @objc open func playerPlaybackStateDidChange(_ noti: NSNotification) {
        MTLog(#function, noti.userInfo, bdPlayer.isPlaying(),bdPlayer.playbackState.rawValue)
    }

    /// 加载状态更新
    @objc open func playerLoadStateDidChange(_ noti: NSNotification) {
        MTLog(#function, noti.userInfo)
    }

    /// 准备播放
    @objc open func playerPlaybackIsPreparedToPlay(_ noti: NSNotification) {
        MTLog(#function, noti.userInfo,bdPlayer.duration)
    }

    /// 播放完毕
    @objc open func playerPlaybackDidFinish(_ noti: NSNotification) {
        if let info = noti.userInfo,
           let reason = info["IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey"] as? Int {
            // 0表示正常结束 1表示非正常结束
            MTLog(#function, noti.userInfo, reason, bdPlayer.isPlaying())
        }
    }

    /// 播放完毕
    @objc open func playerMetadata(_ noti: NSNotification) {
        MTLog(#function, noti.userInfo)
    }

    /// 缓冲开始
    @objc open func playerBufferingStart(_ noti: NSNotification) {
        MTLog(#function, noti.userInfo)
    }

    /// 缓冲更新
    @objc open func playerBufferingUpdate(_ noti: NSNotification) {
        MTLog(#function, noti.userInfo)
    }

    /// 缓冲结束
    @objc open func playerBufferingEnd(_ noti: NSNotification) {
        MTLog(#function, noti.userInfo)
    }

    /// HTTP链接成功
    @objc open func playerHttpConnectEnd(_ noti: NSNotification) {
        MTLog(#function, noti.userInfo)
    }
}
