//
//  MTRequestCacheKey.swift
//  MTPower
//
//  Created by PanGu on 2022/10/19.
//

import Foundation
import Cache

public struct MTRequestCacheKey{
    public static func keyOf(url: String, params: [String:Any]?)->String{
        MD5(url+sort(params ?? [:]))
    }
    
    public static func sort(_ params: [String:Any])-> String{
        var result = ""
        let keys = params.keys.sorted { $0 < $1}
        keys.forEach {result += "\($0)=\(params[$0] ?? "")"}
        return result
    }
}
