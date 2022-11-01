//
//  MTFullPlayerControls_E.swift
//  MTPower
//
//  Created by PanGu on 2022/10/30.
//

import Foundation
// MARK: - OtherView

open class MTPlayerOtherView: UIView {
    public lazy var loadingView: MTFullPlayerLoadingViews = {
        let view = MTFullPlayerLoadingViews()
        return view
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(loadingView)
        loadingView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.height.equalTo(60)
            $0.centerY.equalToSuperview()
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
