//
//  MTCell.swift
//  MTPower
//
//  Created by PanGu on 2022/10/18.
//

import Foundation

public extension UIView {
    static var mt_reusedId: String { NSStringFromClass(Self.self) }
}

public class MT_TableCell<T: UITableViewCell> {
    public static func with(_ tableView: UITableView, indexPath: IndexPath) -> T {
        let cell = tableView.dequeueReusableCell(withIdentifier: T.mt_reusedId, for: indexPath)
        return cell as! T
    }
}

public func MT_sectionRoundRect(of tableView: UITableView,
                                at indexPath: IndexPath,
                                for cell: UITableViewCell,
                                bgColor: UIColor = .white,
                                radius: CGFloat = 8) {
    let layer = CAShapeLayer()
    let rowNum = tableView.numberOfRows(inSection: indexPath.section)
    let cellBounds = cell.bounds
    var roundingCorner = UIRectCorner(rawValue: 0)
    var roundRadius = radius

    switch indexPath.row {
    case let r where r == 0 && r == rowNum - 1:
        roundingCorner = .allCorners
    case let r where r == 0:
        roundingCorner = UIRectCorner(rawValue: UIRectCorner.topLeft.rawValue | UIRectCorner.topRight.rawValue)
    case let r where r == rowNum - 1:
        roundingCorner = UIRectCorner(rawValue: UIRectCorner.bottomLeft.rawValue | UIRectCorner.bottomRight.rawValue)
    default:
        roundRadius = 0
    }

    let path = UIBezierPath(roundedRect: cellBounds, byRoundingCorners: roundingCorner, cornerRadii: .init(width: roundRadius, height: roundRadius))
    layer.path = path.cgPath
    layer.fillColor = bgColor.cgColor
    let cellBgView = UIView()
    cellBgView.layer.insertSublayer(layer, at: 0)
    cell.backgroundView = cellBgView
}

public class MT_CollectionCell<T: UICollectionViewCell>{
    public static func with(_ collectionView: UICollectionView, indexPath: IndexPath) -> T {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: T.mt_reusedId, for: indexPath)
        return cell as! T
    }
}


public class MT_CollectionReuse<T: UICollectionReusableView>{
    public static func header(_ collectionView: UICollectionView,
                              indexPath: IndexPath) -> T{
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                                                     withReuseIdentifier: T.mt_reusedId,
                                                                     for: indexPath)
        return header as! T
    }
    
    public static func footer(_ collectionView: UICollectionView,
                              indexPath: IndexPath) -> T{
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter
                                                                     , withReuseIdentifier: T.mt_reusedId,
                                                                     for: indexPath)
        return header as! T
    }
}
    
