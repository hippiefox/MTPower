//
//  MTProtoTableViewCell.swift
//  MTPower
//
//  Created by PanGu on 2022/10/23.
//

import Foundation
import UIKit

open class MTProtoTableViewCell: UITableViewCell{
    open lazy var iconImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    open lazy var titleLabel: UILabel = UILabel()
    
    open lazy var accessoryImageView: UIImageView = UIImageView()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func configureUI(){
        selectionStyle = .none
        contentView.addSubview(titleLabel)
        contentView.addSubview(iconImageView)
        contentView.addSubview(accessoryImageView)
    }
}
