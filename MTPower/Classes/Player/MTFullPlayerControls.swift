//
//  MTFullPlayerControls.swift
//  MTPower
//
//  Created by PanGu on 2022/10/30.
//

import Foundation

public extension MTFullPlayerControls {
    enum BufferOption {
        case pause
        case play
        case bufferPeriodEnds
        case slideLimit(Float)
        case trialPeriodEnd
    }
}

open class MTFullPlayerControls: MTPlayerControls {
    public var bufferOption: MTValueBlock<BufferOption>?

    // MARK: /*buffer*/

    /// 播放器是否进入播放状态
    public var isReadyToPlay: Bool = false{
        didSet{
            if isReadyToPlay == false{
                hideBufferAnimation()
                toggleItemsDuringBufferPeriod(true)
            }
        }
    }
    /// 解锁控制项的全部功能, 默认值为false
    public var isAccessAllRights: Bool = true {
        didSet {
            if isAccessAllRights { // 解锁功能
                toggleItemsDuringBufferPeriod(true)
                hideBufferAnimation()
            }
        }
    }

    public var bufferItem: MTFullPlayerBufferItem? {
        didSet {
            bufferManager.reset(bufferItem: bufferItem)
        }
    }

    public var bufferManager = MTFullPlayerBufferManager()

    override public var playTime: TimeInterval {
        didSet {
            guard isReadyToPlay == true else { return }
            try2Buffer()
            if bufferManager.isTrying{
                updateTrialUI()
            }
        }
    }

    open func showBufferAnimation() {
        middleView.showLoading()
    }

    open func hideBufferAnimation() {
        middleView.hideLoading()
    }

    private func try2Buffer() {
        guard isAccessAllRights == false else { return }
        guard bufferManager.isStopForAWhile == false else { return }
        guard let bufferItem = bufferItem,
              bufferItem._isBufferable
        else { return }

        if bufferManager.isBuffering { // buffering state
            if bufferManager.pausedDuration > 0,
               bufferManager.pausedDuration % bufferItem.n_waiting_play == 0 {
                // buffer state ends, then enter playing period
                bufferManager.pausedDuration = 0
                bufferManager.isBuffering = false
                toggleItemsDuringBufferPeriod(true)
                hideBufferAnimation()
                bufferOption?(.play)
                return
            }

            showBufferAnimation()
            bufferManager.pausedDuration += 1000
        } else { // playing state
            if bufferManager.playedDuration > 0,
               bufferManager.playedDuration % bufferItem.m_playing_pause == 0
            {
                // play state ends, then enter buffer period
                bufferOption?(.pause)
                bufferManager.playedDuration = 0
                bufferManager.isBuffering = true
                toggleItemsDuringBufferPeriod(false)
                showBuffering()
                return
            }

            bufferManager.playedDuration += 1000
        }
    }

    private func showBuffering() {
        if let tb = bufferItem?.k_trigger_boot,
           tb > 0,
           bufferManager.bufferPeriodCount >= (tb - 1) { // one buffer period ends
            bufferManager.reset(bufferItem: nil)
            hideBufferAnimation()
            toggleItemsDuringBufferPeriod(true)
            bufferOption?(.bufferPeriodEnds)
        } else { // show buffer animation
            bufferManager.bufferPeriodCount += 1
            showBufferAnimation()
        }
    }

    private func toggleItemsDuringBufferPeriod(_ isEnable: Bool) {
        let targetItems: [UIView] = [bottomView.playButton]
        targetItems.forEach { $0.isUserInteractionEnabled = isEnable }
        let targetGestures: [UIGestureRecognizer] = [gestureView.doubleTap, gestureView.longPress, gestureView.pan]
        targetGestures.forEach { $0.isEnabled = isEnable }
    }

    // MARK: /*drag limit*/

    override open func handleOption(_ opt: MTBasicPlayerControls.Option) {
        if case let .slideTo(targetDuration) = opt,
           let bufferItem = bufferItem,
           bufferItem._isLimitDragable,
           isAccessAllRights == false
        {    //trigger drag limit
            let d1 = Float(self.duration) * bufferItem.dragable_ratio
            let d2 = Float(bufferItem.min_drag_duration / 1000)
            let maxDuration = max(d2, d1)
            if targetDuration > maxDuration{
                self.bufferOption?(.slideLimit(maxDuration))
            }else{
                super.handleOption(opt)
            }
            let minDuration = min(targetDuration, maxDuration)
            self.bufferOption?(.slideLimit(minDuration))
        } else {
            super.handleOption(opt)
        }
    }
    
    // MARK: /*trial*/
    private lazy var trialLabel: UILabel = {
        let label = UILabel()
        label.textColor = MTPlayerConfig.tryingColor
        label.font = .systemFont(ofSize: 13)
        return label
    }()
    
    public func startTrial(){
        bufferManager.tryingLeft = bufferManager.__totalTryingSeconds
        guard bufferManager.tryingLeft > 0 else{    return}
        guard bufferManager.isTrying == false else{ return}
        bufferManager.isTrying = true
        isAccessAllRights = true
        trialLabel.isHidden = false
        bufferOption?(.play)
        updateTrialUI()
    }
    
    private func updateTrialUI(){
        trialLabel.text = (MTPlayerConfig.tryingTips ?? "") + "\(bufferManager.tryingLeft)s"
        bufferManager.tryingLeft -= 1
        if bufferManager.tryingLeft <= 0{
            isAccessAllRights = false
            bufferManager.tryingLeft = 0
            bufferManager.isTrying = false
            bufferOption?(.trialPeriodEnd)
            // update trial label tips
            trialLabel.text = MTPlayerConfig.tryingEndTips
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.trialLabel.isHidden = true
            }
        }
    }

    // MARK: /*loading view*/

    public var loadingTips: [String] = [] {
        didSet {
            guard loadingTips.isEmpty == false else { return }

            otherView.loadingView.tips = loadingTips
            otherView.isHidden = false
            otherView.loadingView.startRoll()
        }
    }

    public func hideLoadingTips() {
        otherView.isHidden = true
        otherView.loadingView.stopRoll()
    }

    public lazy var otherView: MTPlayerOtherView = {
        let view = MTPlayerOtherView()
        return view
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        otherView.isHidden = true
        middleView.addSubview(otherView)
        otherView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        trialLabel.isHidden = true
        middleView.addSubview(trialLabel)
        trialLabel.snp.makeConstraints {
            $0.left.equalTo(10)
            $0.top.equalTo(20)
        }
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
