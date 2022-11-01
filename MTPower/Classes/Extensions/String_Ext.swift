//
//  String_Ext.swift
//  MTPower
//
//  Created by PanGu on 2022/10/19.
//

import Foundation

public extension String{
    static func mt_dicFrom(jsonString: String)->[String:Any]?{
        guard jsonString.isEmpty == false,
              let data = jsonString.data(using: .utf8),
              let dic = try? JSONSerialization.jsonObject(with: data,options: .mutableContainers) as? [String:Any]
        else{
            return nil
        }
        return dic
    }
    
    static func mt_setQuery(apurl: String,key: String,value: String)-> String{
        
        guard let urlComp = URLComponents.init(string: apurl),
              let q =  urlComp.query,
              var rawDic = String.mt_dicFrom(jsonString: q)
        else{
            return apurl
        }
        
        rawDic[key] = value
        guard let dicStr = rawDic.mt_2JSONString() else{    return apurl}
        
        let chs = "{}:!@#$^&%*+,\\='\""
        guard let percentCodeStr = dicStr.addingPercentEncoding(withAllowedCharacters: .init(charactersIn: chs).inverted)
        else{   return apurl}
        
        var resultUrl = ""
        if let scheme = urlComp.scheme{
            resultUrl += "\(scheme)://"
        }
        if let host = urlComp.host{
            resultUrl += host
        }
        resultUrl += urlComp.path
        resultUrl += "?\(percentCodeStr)"
        return resultUrl
    }
}
