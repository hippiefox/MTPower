//
//  MTImagePickerConfig.swift
//  MTPower
//
//  Created by PanGu on 2022/11/3.
//

import Foundation
public struct MTImagePickerConfig{
    public static var maxSelectedCount = 0
    
    public static var columnCount = 3
    
    public static var fetchPageSize = 100
    
    public static var itemSpace: CGFloat = 10
    
    public static var sectionInset: UIEdgeInsets = .init(top: (15), left: (15), bottom: (15), right: (15))

    public static func layout(within containerWidth: CGFloat)-> UICollectionViewLayout{
        let layout = UICollectionViewFlowLayout()
        var itemWidth = (containerWidth - (sectionInset.left + sectionInset.right) - CGFloat(columnCount - 1) * itemSpace) / CGFloat(columnCount)
        itemWidth = floor(itemWidth)
        layout.minimumLineSpacing = floor(itemSpace)
        layout.minimumInteritemSpacing = floor(itemSpace)
        layout.sectionInset = sectionInset
        layout.itemSize = .init(width: itemWidth, height: itemWidth)
        return layout
    }
    
    public static var cellSelectedImage: UIImage?
}
