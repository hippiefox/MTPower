//
//  MTDownloaderConfig.swift
//  MTPower
//
//  Created by PanGu on 2022/11/3.
//

import Foundation


public struct MTDownloaderConfig{
    /// 0: unlimited
    public static var downloadLimit = 0
    
    /// download group id
    public static var downloadGroupId: String = ""
    
    ///milliseconds
    public static var dmDownloadRefreshDuration: Int = 2000
    
    /// bytes
    public static var lowSpeed: Int = 8 * 1024 * 1024
    
    public static var highSpeed: Int = 20 * 1024 * 1024
}
