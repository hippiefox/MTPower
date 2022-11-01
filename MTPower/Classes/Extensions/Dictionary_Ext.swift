//
//  Dictionary_Ext.swift
//  MTPower
//
//  Created by PanGu on 2022/10/19.
//

import Foundation



public extension Dictionary{
    func mt_2JSONString()-> String?{
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: []),
              let jsonStr = String(data: data, encoding: .utf8)
        else{   return nil}
        
        return jsonStr
    }
}
