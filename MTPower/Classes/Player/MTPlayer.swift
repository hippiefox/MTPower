//
//  MTPlayer.swift
//  MTPower
//
//  Created by PanGu on 2022/10/27.
//

import Foundation
import SnapKit

/*
    添加手势控制、倍速、画面比例、锁屏、软硬解
 */
open class MTPlayer: MTBasicPlayer{
    open lazy var controlsView: MTPlayerControls = {
        let view = MTPlayerControls()
        view.optionBlock = { [weak self] opt in
            self?.handleControlsOption(opt)
        }
        return view
    }()
    
    public var softHardMode: MTPlayerConfig.SoftHardDecode = .soft
    public var rate: MTPlayerConfig.Rate = .r_1_0
    
    open override func handleControlsOption(_ opt: MTBasicPlayerControls.Option) {
        switch opt{
        case .longPress(let isAcc):
            let rate = isAcc ? 3 : 1
            bdPlayer.playbackRate = Float(rate)
        case .doubleTap:
            if bdPlayer.isPlaying(){
                bdPlayer.pause()
            }else{
                bdPlayer.play()
            }
        case .rate:
            let defaultRate = self.rate
            MTPlayerAlert<MTPlayerConfig.Rate>.showRate(from: self, defaultOpt: defaultRate) { rate in
                self.rate = rate
                self.bdPlayer.playbackRate = rate.rawValue
                (self.__playControl as? MTPlayerControls)?.rate = rate
            }
        case .scale:
            var scale: MTPlayerConfig.Scale!
            switch bdPlayer.scalingMode{
            case .none, .aspectFit: scale = .default
            case .fill: scale = .stretch
            case .aspectFill: scale = .fill
            @unknown default:   break
            }
            MTPlayerAlert<MTPlayerConfig.Scale>.showScale(from: self, defaultOpt: scale, completion: { scale in
                switch scale{
                case .fill: self.bdPlayer.scalingMode = .aspectFill
                case .stretch: self.bdPlayer.scalingMode = .fill
                default:    self.bdPlayer.scalingMode = .aspectFit
                }
            })
        case .pause:
            (self.__playControl as? MTPlayerControls)?.toggleShowAsideViews(true)
            super.handleControlsOption(opt)
        default:    super.handleControlsOption(opt)
        }
    }
    
    open override func setupPlayControls() {
        __playControl = controlsView
    }
    
    open override func playerBufferingEnd(_ noti: NSNotification) {
        super.playerBufferingEnd(noti)
        (self.__playControl as? MTPlayerControls)?.middleView.hideLoading()
    }
    
    open override func playerBufferingStart(_ noti: NSNotification) {
        super.playerBufferingStart(noti)
        (self.__playControl as? MTPlayerControls)?.middleView.showLoading()
    }
}
