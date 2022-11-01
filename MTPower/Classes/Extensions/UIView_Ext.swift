//
//  UIView_Ext.swift
//  MTPower
//
//  Created by PanGu on 2022/10/19.
//

import Foundation
public extension UIView{
    func mt_addPadding(_ inset: UIEdgeInsets){
        frame.size.width += (inset.right + inset.left)
        frame.size.height += (inset.top + inset.bottom)
    }
}
