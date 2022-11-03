//
//  MTProtoCollectionViewCell.swift
//  MTPower
//
//  Created by PanGu on 2022/11/3.
//

import Foundation


open class MTProtoCollectionViewCell: UICollectionViewCell{
    public lazy var iconImageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    public lazy var titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
