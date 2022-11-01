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
            let defaultRate = MTPlayerConfig.Rate.init(rawValue:bdPlayer.playbackRate) ?? .r_1_0
            MTPlayerAlert<MTPlayerConfig.Rate>.showRate(from: self, defaultOpt: defaultRate) { rate in
                self.bdPlayer.playbackRate = rate.rawValue
                self.controlsView.rate = rate
            }
        case .scale:
            var scale: MTPlayerConfig.Scale!
            switch bdPlayer.scalingMode{
            case .none, .aspectFit: scale = .default
            case .fill: scale = .stretch
            case .aspectFill: scale = .fill
            }
            MTPlayerAlert<MTPlayerConfig.Scale>.showScale(from: self, defaultOpt: scale, completion: { scale in
                switch scale{
                case .fill: self.bdPlayer.scalingMode = .aspectFill
                case .stretch: self.bdPlayer.scalingMode = .fill
                default:    self.bdPlayer.scalingMode = .aspectFit
                }
            })
        case .pause:
            if let controlView = basicControlsView as? MTPlayerControls{
                controlView.toggleShowAsideViews(true)
            }
            super.handleControlsOption(opt)
        default:    super.handleControlsOption(opt)
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        basicControlsView.removeFromSuperview()
        basicControlsView = controlsView
        view.addSubview(basicControlsView)
        basicControlsView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    open override func playerBufferingEnd(_ noti: NSNotification) {
        super.playerBufferingEnd(noti)
        controlsView.middleView.hideLoading()
    }
    
    open override func playerBufferingStart(_ noti: NSNotification) {
        super.playerBufferingStart(noti)
        controlsView.middleView.showLoading()
    }
}
