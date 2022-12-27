//
//  MTBoarderRadius.swift
//  MTPower
//
//

import Foundation

public func MT_ViewBoarder(_ view: UIView, _ width: CGFloat, _ color: UIColor){
    view.layer.borderWidth = width
    view.layer.borderColor = color.cgColor
}

public func MT_ViewRadius(_ view: UIView,_ radius: CGFloat){
    view.layer.cornerRadius = radius
    view.layer.masksToBounds = true
}

public func MT_ViewBoarderRadius( view: UIView, _ width: CGFloat, _ color: UIColor,_ radius: CGFloat){
    MT_ViewBoarder(view, width, color)
    MT_ViewRadius(view, radius)
}
