//
//  PlayerControls_E.swift
//  MTPower
//
//  Created by PanGu on 2022/10/26.
//

import Foundation
import SnapKit
import UIKit

// MARK: - ContentView

open class MTPlayerContentView: UIView {}


// MARK: - BottomView

open class MTPlayerBottomView: UIView {
    public var optionBlock: MTValueBlock<MTBasicPlayerControls.Option>?
    public lazy var slider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.isContinuous = true
        slider.addTarget(self, action: #selector(progressSlide), for: .valueChanged)
        slider.addTarget(self, action: #selector(endProgressSlider), for: .touchUpInside)
        slider.tintColor = MTPlayerConfig.progressColor
        if let slideIcon = MTPlayerConfig.slide {
            slider.setThumbImage(slideIcon, for: .normal)
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapSlider(_:)))
        slider.addGestureRecognizer(tap)
        return slider
    }()

    /// normal: play图标, selected: pause图标
    public lazy var playButton: MTButton = {
        let button = __playerAgileButton()
        button.iconNormal = MTPlayerConfig.play
        button.iconSelected = MTPlayerConfig.pause
        button.addTarget(self, action: #selector(actionPlayPause), for: .touchUpInside)
        return button
    }()

    /// 播放时间
    public lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .regular)
        label.textColor = .white
        return label
    }()
    
    /// 旋转按钮
    public lazy var rotateButton: MTButton = {
        let button = __playerAgileButton()
        button.iconNormal = MTPlayerConfig.rotate
        button.addTarget(self, action: #selector(actionRotate), for: .touchUpInside)
        return button
    }()


    override public init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(slider)
        slider.snp.makeConstraints {
            $0.left.equalTo(MT_Baseline(15))
            $0.height.equalTo(MT_Baseline(30))
            $0.right.equalToSuperview().offset(MT_Baseline(-15))
            $0.top.equalToSuperview()
        }
        addSubview(playButton)
        playButton.snp.makeConstraints {
            $0.size.equalTo(MTPlayerConfig.playerItemSize)
            $0.left.equalTo(slider).offset(-MT_Baseline(6))
            $0.top.equalTo(slider.snp.bottom).offset(2)
        }
        addSubview(timeLabel)
        timeLabel.snp.makeConstraints {
            $0.centerY.equalTo(playButton)
            $0.left.equalTo(playButton.snp.right).offset(15)
        }
        addSubview(rotateButton)
        rotateButton.snp.makeConstraints {
            $0.size.equalTo(MTPlayerConfig.playerItemSize)
            $0.right.equalTo(slider)
            $0.centerY.equalTo(playButton)
        }
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc open func progressSlide(_ sender: UISlider) {
        optionBlock?(.sliding(sender.value))
    }

    @objc open func tapSlider(_ sender: UITapGestureRecognizer) {
        let p = sender.location(in: slider)
        let targetValue = (slider.maximumValue - slider.minimumValue) * Float(p.x / slider.bounds.width)
        slider.value = targetValue
        endProgressSlider(slider)
    }

    @objc open func endProgressSlider(_ sender: UISlider) {
        optionBlock?(.slideTo(sender.value))
    }

    @objc private func actionPlayPause(_ sender: MTButton) {
        switch sender.isSelected {
        case true:
            MTLog("去暂停")
            optionBlock?(.pause)
        case false:
            optionBlock?(.play)
            MTLog("去播放")
        }
    }
    
    @objc private func actionRotate(){
        optionBlock?(.rotate)
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for sub in self.subviews{
            if sub.frame.contains(point){
                return sub
            }
        }
        return nil
    }

}

// MARK: - TopView

open class MTPlayerTopView: UIView {
    public var optionBlock: MTValueBlock<MTBasicPlayerControls.Option>?
    public lazy var backButton: MTButton = {
        let button = __playerAgileButton()
        button.iconNormal = MTPlayerConfig.back
        button.addTarget(self, action: #selector(tapBack), for: .touchUpInside)
        return button
    }()

    public lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 2
        label.textColor = .white
        return label
    }()

    @objc private func tapBack() {
        optionBlock?(.close)
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(backButton)
        backButton.snp.makeConstraints {
            $0.size.equalTo(MTPlayerConfig.playerItemSize)
            $0.left.equalTo(MT_Baseline(10))
            $0.centerY.equalToSuperview()
        }
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.left.equalTo(backButton.snp.right).offset(MT_Baseline(10))
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().offset(MT_Baseline(-30))
        }
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


public func __playerAgileButton() -> MTButton {
    let button = MTButton()
    button.iconSize = MTPlayerConfig.playerItemIconSize
    return button
}
