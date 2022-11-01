//
//  MTLottieView.swift
//  MTPower
//
//  Created by PanGu on 2022/10/19.
//

import Foundation
import Lottie

public class MTLottieView: UIView{
    private var animationView: LottieAnimationView
    
    public override var isHidden: Bool{
        didSet{
            if isHidden{
                animationView.stop()
            }
        }
    }
    
    public var text: String?{
        didSet{
            label.text = text
            setNeedsLayout()
        }
    }
    
    public lazy var label: UILabel = {
        let label = UILabel()
        return label
    }()
    
    public init(filePath: String){
        animationView = LottieAnimationView(filePath: filePath)
        animationView.loopMode = .loop
        animationView.backgroundBehavior = .pauseAndRestore
        super.init(frame: .zero)
        addSubview(animationView)
        animationView.play()
        addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        animationView.frame = bounds
        label.sizeToFit()
        label.center.x = animationView.center.x
        label.frame.origin.y = animationView.frame.maxY
    }
    
    public override var intrinsicContentSize: CGSize{   bounds.size}
}
