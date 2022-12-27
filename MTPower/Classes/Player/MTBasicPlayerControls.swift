//
//  MTPlayerControls.swift
//  MTPower
//
//  Created by PanGu on 2022/10/26.
//

import Foundation
import UIKit


open class MTBasicPlayerControls: MTProtoPlayControls {
    
    open var isPlaying: Bool = false {
        didSet {
            bottomView.playButton.isSelected = isPlaying
        }
    }

    public var title: String? {
        didSet {
            topView.titleLabel.text = title
        }
    }
    
    public var duration: TimeInterval = 0{
        didSet{
            bottomView.slider.minimumValue = 0
            bottomView.slider.maximumValue = Float(duration)
        }
    }
    
    public var playTime: TimeInterval = 0{
        didSet{
            let nowTime = Int(playTime).mt_2TimeFormat()
            let totalTime = Int(duration).mt_2TimeFormat()
            bottomView.timeLabel.text = "\(nowTime)/\(totalTime)"
            bottomView.slider.value = Float(playTime)
        }
    }

    public lazy var contentView = MTPlayerContentView()

    public lazy var topView: MTPlayerTopView = {
        let view = MTPlayerTopView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.optionBlock = { [weak self] opt in
            self?.handleOption(opt)
        }
        return view
    }()

    public lazy var bottomView: MTPlayerBottomView = {
        let view = MTPlayerBottomView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.optionBlock = { [weak self] opt in
            self?.handleOption(opt)
        }
        return view
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func handleOption(_ opt: Option) {
        optionBlock?(opt)
    }
}

// MARK: - - Configure UI

extension MTBasicPlayerControls {
    private func configureUI() {
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.left.equalTo(self.safeAreaLayoutGuide.snp.left)
            $0.right.equalTo(self.safeAreaLayoutGuide.snp.right)
            $0.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            $0.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
        }

        contentView.addSubview(topView)
        topView.snp.makeConstraints {
            $0.left.right.top.equalToSuperview()
            $0.height.equalTo(64)
        }

        contentView.addSubview(bottomView)
        bottomView.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.height.equalTo(84)
        }
    }
}
