//
//  Array_Ext.swift
//  MTPower
//
//  Created by PanGu on 2022/10/18.
//

import Foundation

public extension Array{
    func mt_2JSON()-> String?{
        guard let data = try? JSONSerialization.data(withJSONObject: self,options: [.fragmentsAllowed]),
              let str = String(data: data, encoding: .utf8)
        else{   return nil}
        
        return str
    }
}
