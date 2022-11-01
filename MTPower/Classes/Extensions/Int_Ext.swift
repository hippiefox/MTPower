//
//  Int_Ext.swift
//  MTPower
//
//  Created by PanGu on 2022/10/19.
//

import Foundation

public extension Int{
    func mt_2TimeFormat()-> String{
        let second = self
        let h = second / 3600
        let m = second % 3600 / 60
        let s = second % 60
        let hStr = String(format: "%02d", h)
        let mStr = String(format: "%02d", m)
        let sStr = String(format: "%02d", s)
        if h > 0 { return "\(hStr):\(mStr):\(sStr)" }
        if m > 0 { return "\(mStr):\(sStr)" }
        return "0:\(sStr)"
    }
}

