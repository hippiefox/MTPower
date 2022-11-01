//
//  MTColor.swift
//  MTPower
//
//  Created by PanGu on 2022/10/18.
//

import Foundation

public func MT_COLOR(_ r: CGFloat,_ g: CGFloat,_ b: CGFloat) -> UIColor{
    UIColor(red: r/255, green: g/255, blue: b/255, alpha: 1)
}

/// COLOR rgba
/// - Parameters:
///   - r: red
///   - g: green
///   - b: blue
///   - a: alpha  value range [0,1]
/// - Returns: A Color
public func MT_COLORA(_ r: CGFloat,_ g: CGFloat,_ b: CGFloat,_ a: CGFloat) -> UIColor{
    UIColor(red: r/255, green: g/255, blue: b/255, alpha: a)
}


/// COLOR Hex
/// - Parameter value: "#","0x","0X"
/// - Returns: a color
public func MT_COLOR(hex value: String)-> UIColor?{
    var offset = 0
    if value.hasPrefix("#"){offset = 1}
    if value.hasPrefix("0x") || value.hasPrefix("0X"){  offset = 2}
    // strip off prefix
    let hexStr = value[value.index(value.startIndex, offsetBy: offset)..<value.endIndex]
    let scanner = Scanner(string: .init(hexStr))
    var hexValue: UInt64 = 0
    let isValidHex = scanner.scanHexInt64(&hexValue)
        
    guard isValidHex,
          (hexStr.count == 6 || hexStr.count == 8)
    else{   return nil}
    
    var r: CGFloat = 0, g:CGFloat = 0, b:CGFloat = 0, a:CGFloat = 1
    if hexStr.count == 6{
        r = CGFloat((hexValue&0xFF0000)>>16) / 255
        g = CGFloat((hexValue&0x00FF00)>>8) / 255
        b = CGFloat((hexValue&0x0000FF)>>0) / 255
    }
    if hexStr.count == 8{
        r = CGFloat((hexValue&0xFF000000)>>24) / 255
        g = CGFloat((hexValue&0x00FF0000)>>16) / 255
        b = CGFloat((hexValue&0x0000FF00)>>8) / 255
        a = CGFloat((hexValue&0x000000FF)>>0) / 255
    }
    return UIColor(red: r, green: g, blue: b, alpha: a)
}
