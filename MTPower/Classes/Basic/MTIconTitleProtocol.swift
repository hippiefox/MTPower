//
//  MTIconTitleProtocol.swift
//  MTPower
//
//  Created by PanGu on 2022/10/18.
//

import Foundation

public protocol MTIconTitleProtocol{
    var title: String?{get}
    var icon: UIImage?{get}
    var iconSize: CGSize{get}
}
