//
//  MTIconTextItem.swift
//  MTPower
//

import Foundation

public protocol MTIconTextItem {
    var text: String? { get }
    var icon: UIImage? { get }
}

public protocol MTIconTextSizeItem {
    var text: String? { get }
    var icon: UIImage? { get }
    var iconSize: CGSize { get }
}
