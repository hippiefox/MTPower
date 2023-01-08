//
//  UILabel_Ext.swift
//  MTPower
//
//  Created by PanGu on 2022/10/19.
//

import Foundation
import UIKit

public extension UILabel {
    convenience init(font: UIFont, textColor: UIColor?, text: String? = nil) {
        self.init()
        self.font = font
        self.textColor = textColor
        self.text = text
    }

    convenience init(fontSize: CGFloat, textColor: UIColor?, text: String? = nil) {
        self.init(font: .systemFont(ofSize: fontSize), textColor: textColor, text: text)
    }
}
