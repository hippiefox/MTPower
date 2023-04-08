//
//  MTSpringButton.swift
//  MTPower
//
//  Created by pulei yu on 2023/4/8.
//

import Foundation

open class MTSpringButton: MTButton{
    public var maxHeight: CGFloat = 0
    public var maxWidth: CGFloat = 0
    public var contentInset: UIEdgeInsets = .zero
    
    
    open override var isSelected: Bool{
        didSet{
            invalidateIntrinsicContentSize()
        }
    }
    
    open override var intrinsicContentSize: CGSize {
       
        var text = titleNormal ?? ""
        
        if isSelected && titleSelected != nil{
            text = titleSelected!
        }
        
        var titleSize = CGSize.zero
        if text.isEmpty == false {
            titleSize = (text as NSString).boundingRect(with: .init(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
                                                        options: .usesLineFragmentOrigin,
                                                        attributes: [.font: titleFont],
                                                        context: nil).size
            titleSize = .init(width: ceil(titleSize.width), height: ceil(titleSize.height))
        }

        let gap = self.gap
        let iconSize = self.iconSize
        var contentSize: CGSize = .zero

        switch position {
        case .top, .bottom:
            if maxWidth > 0 {
                contentSize = .init(width: maxWidth, height: iconSize.height + gap + titleSize.height)
            } else {
                contentSize = .init(width: max(iconSize.width, titleSize.width), height: iconSize.height + gap + titleSize.height)
            }
            contentSize = .init(width: contentSize.width + contentInset.left + contentInset.right, height: contentSize.height + contentInset.top + contentInset.bottom)
        case .left, .right:
            if maxHeight > 0 {
                contentSize = .init(width: iconSize.width + gap + titleSize.width, height: maxHeight)
            } else {
                contentSize = .init(width: iconSize.width + gap + titleSize.width, height: max(iconSize.height, titleSize.height))
            }
            contentSize = .init(width: contentSize.width + contentInset.left + contentInset.right, height: contentSize.height + contentInset.top + contentInset.bottom)
        }

        return contentSize
    }
}
