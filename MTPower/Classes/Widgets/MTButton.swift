//
//  MTButton.swift
//  MTPower
//
//  Created by PanGu on 2022/10/23.
//

import Foundation
extension MTButton {
    public enum IconPosition {
        case top
        case bottom
        case left
        case right
    }
}

open class MTButton: UIControl {
    public var maxHeight: CGFloat = 0
    public var maxWidth: CGFloat = 0
    public var contentInset: UIEdgeInsets = .zero
    public var isFlexSize: Bool = false
    
    public var position: IconPosition = .top {
        didSet {
            setNeedsLayout()
        }
    }

    public var gap: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }

    public var iconSize: CGSize = .zero {
        didSet {
            setNeedsLayout()
        }
    }

    public var iconNormal: UIImage? {
        didSet { imageView.image = iconNormal }
    }

    public var iconSelected: UIImage?

    public var iconDisabled: UIImage?

    public var titleNormal: String? {
        didSet {
            titleLabel.text = titleNormal
            setNeedsLayout()
        }
    }

    public var titleSelected: String?

    public var titleDisabled: String?

    public var titleFont: UIFont = .systemFont(ofSize: 12) {
        didSet {
            titleLabel.font = titleFont
            setNeedsLayout()
        }
    }

    public var titleColorNormal: UIColor = .black {
        didSet {
            titleLabel.textColor = titleColorNormal
        }
    }

    public var titleColorSelected: UIColor?

    public var titleColorDisabled: UIColor?

    public lazy var imageView: UIImageView = {
        let view = UIImageView()
        return view
    }()

    public lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = titleFont
        return label
    }()

    override public var isSelected: Bool {
        didSet {
            if isSelected {
                imageView.image = iconSelected == nil ? iconNormal : iconSelected
                titleLabel.text = titleSelected == nil ? titleNormal : titleSelected
                titleLabel.textColor = titleColorSelected == nil ? titleColorNormal : titleColorSelected
            } else {
                imageView.image = iconNormal
                titleLabel.text = titleNormal
                titleLabel.textColor = titleColorNormal
            }
            if isFlexSize{
                invalidateIntrinsicContentSize()
            }
            setNeedsLayout()
        }
    }
    
    override public var intrinsicContentSize: CGSize {
        guard isFlexSize == true else{  return super.intrinsicContentSize}
        
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
            contentSize = .init(width: contentSize.width, height: contentSize.height + contentInset.top + contentInset.bottom)
        case .left, .right:
            if maxHeight > 0 {
                contentSize = .init(width: iconSize.width + gap + titleSize.width, height: maxHeight)
            } else {
                contentSize = .init(width: iconSize.width + gap + titleSize.width, height: max(iconSize.height, titleSize.height))
            }
            contentSize = .init(width: contentSize.width + contentInset.left + contentInset.right, height: contentSize.height)
        }

        return contentSize
    }

    override public var isEnabled: Bool {
        didSet {
            if isEnabled == false {
                imageView.image = iconDisabled == nil ? iconNormal : iconDisabled
                titleLabel.text = titleSelected == nil ? titleNormal : titleDisabled
                titleLabel.textColor = titleColorDisabled == nil ? titleColorNormal : titleColorDisabled
            } else {
                imageView.image = iconNormal
                titleLabel.text = titleNormal
                titleLabel.textColor = titleColorNormal
            }
            setNeedsLayout()
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        addSubview(imageView)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        calculateTextSize(bounds)
        calculateImageSize(bounds)
        calculateTextOrigin(bounds)
        calculateImageOrigin(bounds)
    }
}

// MARK: Calculate

extension MTButton {
    private func calculateTextSize(_ rect: CGRect) {
        var rectWidth: CGFloat = 0
        
        switch position {
        case .top, .bottom: rectWidth = rect.width
        case .left, .right: rectWidth = rect.width - gap - iconSize.width
        }

        let text = titleLabel.text ?? ""
        var textSize = CGSize.zero

        if text.isEmpty == false {
            textSize = (text as NSString).boundingRect(with: .init(width: rectWidth, height: CGFloat.greatestFiniteMagnitude),
                                                       options: .usesLineFragmentOrigin,
                                                       attributes: [.font: titleFont],
                                                       context: nil).size
        }
        if textSize != .zero {
            titleLabel.frame.size = .init(width: ceil(textSize.width), height: ceil(textSize.height))
        }
    }

    private func calculateImageSize(_ rect: CGRect) {
        imageView.frame.size = iconSize
    }

    private func calculateTextOrigin(_ rect: CGRect) {
        var x: CGFloat = 0, y: CGFloat = 0
        switch position {
        case .top:
            x = (rect.width - titleLabel.frame.size.width) / 2
            y = (rect.height - iconSize.height - gap - titleLabel.frame.height) / 2 + iconSize.height + gap
        case .bottom:
            x = (rect.width - titleLabel.frame.size.width) / 2
            y = (rect.height - iconSize.height - gap - titleLabel.frame.height) / 2
        case .left:
            x = (rect.width - titleLabel.frame.size.width - iconSize.width - gap) / 2 + iconSize.width + gap
            y = (rect.height - titleLabel.frame.size.height) / 2
        case .right:
            x = (rect.width - titleLabel.frame.size.width - iconSize.width - gap) / 2
            y = (rect.height - titleLabel.frame.size.height) / 2
        }

        titleLabel.frame.origin = CGPoint(x: x, y: y)
    }

    private func calculateImageOrigin(_ rect: CGRect) {
        var x: CGFloat = 0, y: CGFloat = 0
        switch position {
        case .top:
            x = (rect.width - iconSize.width) / 2
            y = (rect.height - iconSize.height - gap - titleLabel.frame.height) / 2
        case .bottom:
            x = (rect.width - iconSize.width) / 2
            y = (rect.height - iconSize.height - gap - titleLabel.frame.height) / 2 + gap + titleLabel.frame.size.height
        case .left:
            x = (rect.width - titleLabel.frame.size.width - iconSize.width - gap) / 2
            y = (rect.height - iconSize.height) / 2
        case .right:
            x = (rect.width - titleLabel.frame.size.width - iconSize.width - gap) / 2 + titleLabel.frame.size.width + gap
            y = (rect.height - iconSize.height) / 2
        }

        imageView.frame.origin = CGPoint(x: x, y: y)
    }
}
