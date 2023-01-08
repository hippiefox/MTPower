//
//  MTPlayerControls.swift
//  MTPower
//
//  Created by PanGu on 2022/10/27.
//

import Foundation
import MediaPlayer
import UIKit

open class MTPlayerControls: MTBasicPlayerControls {
    public lazy var appendixView: MTPlayerAppdendixView = {
        let view = MTPlayerAppdendixView()
        view.optionBlock = { [weak self] opt in
            self?.handleOption(opt)
        }
        return view
    }()

    public lazy var gestureView: MTPlayerGestureView = {
        let view = MTPlayerGestureView()
        view.gestureOptionBlock = { [weak self] opt in
            self?.handleGestureOption(opt)
        }
        return view
    }()

    public lazy var middleView: MTPlayerMiddleView = {
        let view = MTPlayerMiddleView()
        view.isUserInteractionEnabled = false
        return view
    }()
    
    // 播放器倍速
    public var rate: MTPlayerConfig.Rate = .r_1_0{
        didSet{
            rateButton.titleNormal = String(format: "%.2f", rate.rawValue)
        }
    }
    public lazy var rateButton: PlayerRateButton = {
        let button = PlayerRateButton()
        button.titleNormal = "1.0"
        button.addTarget(self, action: #selector(actionRate), for: .touchUpInside)
        return button
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: /*actions*/
    open override func handleOption(_ opt: MTBasicPlayerControls.Option) {
        switch opt{
        case .sliding(let playtime):
            showPlaybackTimeTips(TimeInterval(playtime))
        case .slideTo:
            middleView.hideTips()
        case .lock(let isLock):
            self.isLock = isLock
        default:    break
        }
        super.handleOption(opt)
    }
    
    @objc private func actionRate(){
        handleOption(.rate)
    }
    
    // MARK: /*锁屏处理*/
    private var isLock: Bool = false{
        didSet{
            gestureView.doubleTap.isEnabled = !isLock
            gestureView.longPress.isEnabled = !isLock
            gestureView.pan.isEnabled = !isLock
            toggleShowAsideViews(!isLock)
            if isLock{
                appendixView.lockButton.isHidden = false
            }
        }
    }

    // MARK: /*自动隐藏处理*/
    private var lastTouchTime = Date().timeIntervalSince1970
    override open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        lastTouchTime = Date().timeIntervalSince1970
        return super.hitTest(point, with: event)
    }
    
    public override var playTime: TimeInterval{
        didSet{
            adjustItemsLayout()
        }
    }
    
    private func adjustItemsLayout(){
        let now = Date().timeIntervalSince1970
        let isLongerEnough = now - lastTouchTime > MTPlayerConfig.playerAutoHideItemsDuration
        
        if isPlaying,isLongerEnough{
            if isLock{
                appendixView.lockButton.isHidden = true
            }else{
                toggleShowAsideViews(false)
            }
        }
    }

    // MARK: /*滑动手势处理*/

    private var panStartValue: TimeInterval = 0
    private var panBrightnessTime: Int = 0
    public lazy var volumeSlider: UISlider = {
        let volumeView = MPVolumeView(frame: .init(x: 0, y: 0, width: 200, height: 6))
        volumeView.showsVolumeSlider = false
        volumeView.showsRouteButton = false
        var volumViewSlider = UISlider()
        for subView in volumeView.subviews {
            if type(of: subView).description() == "MPVolumeSlider" {
                volumViewSlider = subView as! UISlider
                return volumViewSlider
            }
        }
        return volumViewSlider
    }()

    open func handleGestureOption(_ opt: MTPlayerGestureView.GestureOption) {
        switch opt {
        case .tapOnce:
            if isLock{
                appendixView.lockButton.isHidden = false
            }else{
                toggleShowAsideViews(!isShowAsideViews)
            }
        case let .panning(optionValue):
            let option = optionValue.0
            let gapValue = optionValue.1
            switch option {
            case .progress:
                if panStartValue == 0 {
                    panStartValue = playTime
                }
                panStartValue += TimeInterval(gapValue)
                panStartValue = max(0, panStartValue)
                panStartValue = min(duration, panStartValue)
                showPlaybackTimeTips(panStartValue)
            case .none:
                clearPanGestureState()
            case .lightness:
                // iOS16下的调节亮度有一个最小的阈值
                if #available(iOS 16, *) {
                    panBrightnessTime += 1
                    if panBrightnessTime % 3 == 0 {
                        let value = gapValue >= 0 ? 0.03 : -0.03
                        UIScreen.main.brightness += CGFloat(value)
                    }
                } else {
                    UIScreen.main.brightness += CGFloat(gapValue)
                }
                showLightnessTips()
            case .volume:
                volumeSlider.value += volumeSlider.maximumValue * gapValue
                showVolumeTips()
            }
        case let .panDone(option):
            switch option {
            case .progress:
                handleOption(.slideTo(Float(panStartValue)))
            default: break
            }
            clearPanGestureState()
            middleView.hideTips()
        case let .longPress(isLongPress):
            handleOption(.longPress(isLongPress))
        case .tapTwice:
            handleOption(.doubleTap)
        }
    }

    func clearPanGestureState() {
        panStartValue = 0
        panBrightnessTime = 0
    }

    // MARK: /*控件的展示与隐藏*/

    public var isShowAsideViews: Bool = true{
        didSet{
            if isShowAsideViews{
                self.backgroundColor = MTPlayerConfig.playerControlsPauseBackgroundColor
            }else{
                self.backgroundColor = .clear
            }
        }
    }

    public func toggleShowAsideViews(_ isShow: Bool) {
        isShowAsideViews = isShow
        let apViews = appendixView.subviews
        let asideViews = [bottomView, topView] + apViews
        asideViews.forEach {
            $0.isHidden = !isShow
        }
    }

    // MARK: /*状态展示*/

    private func showPlaybackTimeTips(_ tipsTime: TimeInterval) {
        let toTimeStr = Int(tipsTime).mt_2TimeFormat()
        let str = toTimeStr + " / " + Int(duration).mt_2TimeFormat()
        let toTimeRange = (str as NSString).range(of: toTimeStr)
        let mAttr = NSMutableAttributedString(string: str)
        mAttr.addAttributes([.foregroundColor: UIColor.white,.font: UIFont.systemFont(ofSize: 30, weight: .medium)], range: toTimeRange)
        middleView.showTimeTips(mAttr)
    }

    private func showVolumeTips() {
        let volumeRatio = volumeSlider.value / (volumeSlider.maximumValue == 0 ? 1 : volumeSlider.maximumValue)
        let ratioStr = "\(Int(volumeRatio * 100))%"
        middleView.showVolumeTips(ratioStr)
    }

    private func showLightnessTips() {
        let ratioStr = "\(Int(UIScreen.main.brightness * 100))%"
        middleView.showBrightnessTips(ratioStr)
    }
}

// MARK: - - Configure UI

extension MTPlayerControls {
    private func configureUI() {
        contentView.addSubview(middleView)
        middleView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(bottomView.snp.top)
            $0.top.equalTo(topView.snp.bottom)
        }
        contentView.addSubview(appendixView)
        appendixView.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-10)
            $0.bottom.equalTo(bottomView.snp.top).offset(-20)
        }
        contentView.insertSubview(gestureView, at: 0)
        gestureView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        bottomView.addSubview(rateButton)
        rateButton.snp.makeConstraints {
            $0.size.equalTo(MTPlayerConfig.playerItemSize)
            $0.centerY.equalTo(bottomView.rotateButton)
            $0.right.equalTo(bottomView.rotateButton.snp.left).offset(-6)
        }
        
    }
}
