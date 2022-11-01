//
//  Date_Ext.swift
//  MTPower
//
//  Created by PanGu on 2022/10/19.
//

import Foundation

public extension Date{
    /// millisecond
    var mt_milliTimeStamp: Int{
        let ti: TimeInterval = self.timeIntervalSince1970
        let millisecond = CLongLong(round(ti * 1000))
        return Int(millisecond)
    }
    
    /// second
    var mt_secondTimeStamp: Int{
        let ti: TimeInterval = self.timeIntervalSince1970
        return Int(ti)
    }
    
    /// covert timeStamp to date string
    static func mt_convert(timeStamp: TimeInterval, to dateFormat: String = "YYYY-MM-dd HH:mm")-> String{
        let date = Date(timeIntervalSince1970: timeStamp)
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.string(from: date)
    }
}
