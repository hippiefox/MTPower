//
//  MTPlayerControls_E.swift
//  MTPower
//
//  Created by PanGu on 2022/10/27.
//

import Foundation

// MARK: - GestureView

public extension MTPlayerGestureView {
    enum GestureOption {
        case tapOnce
        case tapTwice
        case panning((PanOption, Float))
        case panDone(PanOption)
        case longPress(Bool)
    }

    /// 滑动操作
    enum PanOption: String {
        case none
        case volume
        case lightness
        case progress
    }
}

open class MTPlayerGestureView: UIView, UIGestureRecognizerDelegate {
    public var gestureOptionBlock: MTValueBlock<GestureOption>?

    public lazy var tap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(actionTap(_:)))
        tap.delegate = self
        return tap
    }()

    public lazy var doubleTap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(actionDoubleTap(_:)))
        tap.numberOfTapsRequired = 2
        tap.delegate = self
        return tap
    }()

    public lazy var longPress: UILongPressGestureRecognizer = {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(actionLongPress(_:)))
        longPress.delegate = self
        longPress.minimumPressDuration = 1
        return longPress
    }()

    public lazy var pan: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(actionPanSelf(_:)))
        pan.delegate = self
        return pan
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        addGestureRecognizer(tap)
        addGestureRecognizer(longPress)
        addGestureRecognizer(pan)
        addGestureRecognizer(doubleTap)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func actionTap(_ gesture: UITapGestureRecognizer) {
        gestureOptionBlock?(.tapOnce)
    }

    private var isLongPress = false {
        didSet {
            if isLongPress != oldValue {
                gestureOptionBlock?(.longPress(isLongPress))
            }
        }
    }

    @objc private func actionDoubleTap(_ gesture: UITapGestureRecognizer) {
        gestureOptionBlock?(.tapTwice)
    }

    @objc private func actionLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began, .changed:
            isLongPress = true
        default:
            isLongPress = false
        }
    }

    private var panOption: PanOption = .none
    private var startPanLocation: CGPoint = .zero
    @objc private func actionPanSelf(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            startPanLocation = gesture.location(in: self)
        case .changed:
            let loc = gesture.location(in: self)
            let xPan = loc.x - startPanLocation.x
            let yPan = loc.y - startPanLocation.y

            // 首次移动，判断操作手势
            if panOption == .none {
                if xPan != 0 {
                    panOption = .progress
                } else if yPan != 0 {
                    if loc.x < frame.size.width / 2 {
                        panOption = .lightness
                    } else if loc.x > frame.size.width / 2 {
                        panOption = .volume
                    }
                }
                // 修正移动手势
                if xPan != 0 {
                    let absX = abs(xPan)
                    let absY = abs(yPan)
                    if absY / absX > 1.8 {
                        if loc.x < frame.size.width / 2 {
                            panOption = .lightness
                        } else if loc.x > frame.size.width / 2 {
                            panOption = .volume
                        }
                    }
                }
            }

            switch panOption {
            case .none: break
            case .volume:
                let slideFrame = Float(frame.height)
                let panGap = Float(-yPan) / slideFrame
                gestureOptionBlock?(.panning((.volume, panGap)))
            case .lightness:
                let slideFrame = Float(frame.height)
                let panGap = Float(-yPan) / slideFrame
                gestureOptionBlock?(.panning((.lightness, panGap)))
            case .progress:
                let slideDuration = MTPlayerConfig.playerSlideDuration
                let frameWidth = Float(frame.width == 0 ? 1 : frame.width)
                let panGap = slideDuration * Float(xPan) / frameWidth
                gestureOptionBlock?(.panning((.progress, panGap)))
            }
            startPanLocation = loc
        case .ended:
            gestureOptionBlock?(.panDone(panOption))
            panOption = .none
            startPanLocation = .zero
        default:
            // 手势被打断
            gestureOptionBlock?(.panDone(.none))
            panOption = .none
            startPanLocation = .zero
        }
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == tap,
           otherGestureRecognizer == doubleTap {
            return true
        }

        if gestureRecognizer == longPress, otherGestureRecognizer == pan {
            return true
        }

        return false
    }
}

// MARK: - MiddleView

/*
    middleView hierachy
    - tipsContainer
        - timeTipsLabel
        - brightnessTipsView
        - volumeTipsView
    - bufferContainer
 */

open class MTPlayerMiddleView: UIView {
    //MARK: (Buffer)
    private lazy var bufferContainer: UIView = UIView()
    public var bufferingLottiePath: String!
    open func showLoading(){
        guard let path = bufferingLottiePath else{   return}
        
        guard bufferContainer.isHidden == true else{   return}
        bufferContainer.isHidden = false
        let lottie = MTLottieView.init(filePath: path)
        lottie.frame = .init(x: 0, y: 0, width: MT_Baseline(100), height: MT_Baseline(100))
        MTHUD.showCustomView(lottie,onView: bufferContainer)
    }
    
    open func hideLoading(){
        bufferContainer.isHidden = true
        MTHUD.hide(onView: bufferContainer)
        bufferContainer.subviews.forEach {
            $0.isHidden = true
            $0.removeFromSuperview()
        }
    }
    
    // MARK: (提示语)

    private lazy var tipsContainer: UIView = UIView()
    private lazy var timeTipsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 26, weight: .medium)
        label.textColor = .white.withAlphaComponent(0.7)
        return label
    }()

    public lazy var brightnessTipsView: MTButton = {
        let button = __playerAgileButton()
        button.gap = 6
        button.iconSize = .init(width: 40, height: 40)
        button.position = .top
        button.iconNormal = MTPlayerConfig.brightness
        button.titleFont = .systemFont(ofSize: 12, weight: .medium)
        button.titleColorNormal = .white
        button.isEnabled = false
        return button
    }()

    public lazy var volumeTipsView: MTButton = {
        let button = __playerAgileButton()
        button.iconSize = .init(width: 40, height: 40)
        button.iconNormal = MTPlayerConfig.volume
        button.position = .top
        button.titleFont = .systemFont(ofSize: 12, weight: .medium)
        button.gap = 6
        button.titleColorNormal = .white
        button.isEnabled = false
        return button
    }()

    public func showTimeTips(_ tips: NSAttributedString) {
        tipsContainer.isHidden = false
        timeTipsLabel.isHidden = false
        timeTipsLabel.attributedText = tips
    }

    public func showBrightnessTips(_ tips: String) {
        tipsContainer.isHidden = false
        brightnessTipsView.isHidden = false
        brightnessTipsView.titleNormal = tips
    }

    public func showVolumeTips(_ tips: String) {
        tipsContainer.isHidden = false
        volumeTipsView.isHidden = false
        volumeTipsView.titleNormal = tips
    }

    public func hideTips() {
        tipsContainer.subviews.forEach { $0.isHidden = true }
        tipsContainer.isHidden = true
    }

    // MARK: (缓冲图层)

    override public init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(tipsContainer)
        tipsContainer.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        tipsContainer.addSubview(timeTipsLabel)
        timeTipsLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        tipsContainer.addSubview(brightnessTipsView)
        brightnessTipsView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(CGSize(width: 100, height: 100))
        }
        tipsContainer.addSubview(volumeTipsView)
        volumeTipsView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(CGSize(width: 100, height: 100))
        }

        hideTips()
        
        bufferContainer.isHidden = true
        addSubview(bufferContainer)
        bufferContainer.snp.makeConstraints {
            $0.width.height.equalTo(MT_Baseline(200))
            $0.center.equalToSuperview()
        }
        
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - AppdendixView

open class MTPlayerAppdendixView: UIView {
    public var optionBlock: MTValueBlock<MTPlayerControls.Option>?

    public var buttonItems: [UIView] = [] {
        didSet {
            layoutItems()
            invalidateIntrinsicContentSize()
        }
    }

    public lazy var lockButton: MTButton = {
        let button = __playerAgileButton()
        button.iconNormal = MTPlayerConfig.unlock
        button.iconSelected = MTPlayerConfig.lock
        button.gap = 3
        button.titleFont = .systemFont(ofSize: 10)
        button.titleColorNormal = .white
        button.titleNormal = MTPlayerConfig.unlockString
        button.titleSelected = MTPlayerConfig.lockString
        button.position = .top
        button.addTarget(self, action: #selector(actionLock), for: .touchUpInside)
        return button
    }()

    public lazy var softHardButton: MTButton = {
        let button = __playerAgileButton()
        button.titleColorNormal = .white
        button.titleFont = .systemFont(ofSize: 10)
        button.gap = 3
        button.position = .top
        button.iconNormal = MTPlayerConfig.softHardDecode
        button.addTarget(self, action: #selector(actionSoftHard), for: .touchUpInside)
        return button
    }()

    public lazy var scaleButton: MTButton = {
        let button = __playerAgileButton()
        button.titleColorNormal = .white
        button.titleFont = .systemFont(ofSize: 10)
        button.gap = 3
        button.position = .top
        button.iconNormal = MTPlayerConfig.scale
        button.titleNormal = MTPlayerConfig.scaleString
        button.addTarget(self, action: #selector(actionScale), for: .touchUpInside)
        return button
    }()

    @objc private func actionLock(_ sender: MTButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            optionBlock?(.lock(true))
        } else {
            optionBlock?(.lock(false))
        }
    }

    @objc private func actionSoftHard() {
        optionBlock?(.softHard)
    }

    @objc private func actionScale() {
        optionBlock?(.scale)
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        buttonItems = [lockButton, scaleButton]
        layoutItems()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let itemSpace: CGFloat = 6
    private let itemHeight: CGFloat = 44
    private func layoutItems() {
        subviews.forEach { $0.removeFromSuperview() }
        var preview: UIView?
        let items = buttonItems.reversed()
        items.forEach {
            addSubview($0)
            $0.snp.makeConstraints { make in
                make.width.height.equalTo(itemHeight)
                make.centerX.equalToSuperview()
                if preview == nil {
                    make.bottom.equalToSuperview()
                } else {
                    make.bottom.equalTo(preview!.snp.top).offset(-itemSpace)
                }
            }
            preview = $0
        }
    }

    override open var intrinsicContentSize: CGSize {
        let height = CGFloat(buttonItems.count) * (itemSpace + itemHeight)
        let width = itemHeight
        return CGSize(width: width, height: height)
    }
}

// MARK: Rate Button

public class PlayerRateButton: MTButton {
    private var itemSize: CGSize = MTPlayerConfig.playerItemIconSize

    private lazy var itemBoundsView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        MT_ViewBoarderRadius(view: view, 1, .white, 0)
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        titleColorNormal = .white
        titleFont = .systemFont(ofSize: 10)
        insertSubview(itemBoundsView, at: 0)
        itemBoundsView.snp.makeConstraints {
            $0.size.equalTo(itemSize)
            $0.center.equalToSuperview()
        }
    }
}
