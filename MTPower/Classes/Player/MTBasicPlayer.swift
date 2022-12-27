//
//  MTBasicPlayer.swift
//  MTPower
//
//  Created by PanGu on 2022/10/26.
//

import Foundation
import BDCloudMediaPlayer


/*
    实现播放器的基本UI交互：
    播放/暂停、时间进度显示、屏幕旋转、关闭、播放文件的名称展示
 */
open class MTBasicPlayer: MTProtoPlayer{
    
    open lazy var basicControlsView: MTBasicPlayerControls = {
        let view = MTBasicPlayerControls()
        view.optionBlock = { [weak self] opt in
            self?.handleControlsOption(opt)
        }
        return view
    }()
    
    //MARK: (override)
    open override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    open override func setupPlayControls() {
        __playControl = basicControlsView
    }
        
    open override var prefersStatusBarHidden: Bool{ true}
    
    open override func playerPlaybackIsPreparedToPlay(_ noti: NSNotification) {
        super.playerPlaybackIsPreparedToPlay(noti)
        (__playControl as? MTBasicPlayerControls)?.duration = bdPlayer.duration
        // 配置拖拽手势的时长
        MTPlayerConfig.playerSlideDuration = min(Float(bdPlayer.duration), MTPlayerConfig.__defaultPlayerSlideDuration)
        startTimer()
    }
    
    open override func playerPlaybackStateDidChange(_ noti: NSNotification) {
        super.playerPlaybackStateDidChange(noti)
        (__playControl as? MTBasicPlayerControls)?.isPlaying = bdPlayer.isPlaying()
    }
    
    open override func playerPlaybackDidFinish(_ noti: NSNotification) {
        super.playerPlaybackDidFinish(noti)
        stopTimer(isPlayEnd: true)
    }
    
    public var __timer: DispatchSourceTimer?
    open func startTimer(){
        stopTimer(isPlayEnd: false)
        let timeSource = DispatchSource.makeTimerSource(flags: .init(rawValue: 0), queue: DispatchQueue.global())
        timeSource.schedule(deadline: .now(), repeating: .milliseconds(1000))
        timeSource.setEventHandler {
            DispatchQueue.main.async {
                self.timerBeat()
            }
        }
        timeSource.activate()
        __timer = timeSource
    }
    
    open func stopTimer(isPlayEnd:Bool = false){
        MTLog(#function,"isPlayEnd:\(isPlayEnd)")
        __timer?.cancel()
        __timer = nil
        if isPlayEnd{
            (__playControl as? MTBasicPlayerControls)?.playTime = 0
        }
    }
    
    open func timerBeat(){
        (__playControl as? MTBasicPlayerControls)?.playTime = bdPlayer.currentPlaybackTime
    }
    
    open func handleControlsOption(_ opt: MTBasicPlayerControls.Option){
        switch opt{
        case .close:actionClose()
        case .play: actionPlay()
        case .pause:actionPause()
        case .slideTo(let time):actionSlideTo(time: time)
        case .rotate:actionRotate()
        default:    break
        }
    }
}

//MARK: Actions
extension MTBasicPlayer{
    @objc open func actionClose(){
        stopTimer()
        dismiss(animated: true)
    }
    
    @objc open func actionPlay(){
        if bdPlayer.playbackState == .stopped{
            configurePlayer()
        }else{
            bdPlayer.play()
        }
    }
    
    @objc open func actionPause(){
        if bdPlayer.playbackState == .stopped{
            configurePlayer()
        }else{
            bdPlayer.pause()
        }
    }
    
    @objc open func actionSlideTo(time:Float){
        bdPlayer.currentPlaybackTime = TimeInterval(time)
    }
    
    @objc open func actionRotate(){
        MTDeviceOrientation.rotateToggle()
    }
}

//MARK:-- Configure UI
extension MTBasicPlayer{
    private func configureUI(){
        view.addSubview(__playControl)
        __playControl.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

