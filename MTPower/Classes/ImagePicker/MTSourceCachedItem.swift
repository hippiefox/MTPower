//
//  MTSourceCachedItem.swift
//  MTPower
//
//  Created by PanGu on 2022/11/2.
//

import Foundation

public struct MTSourceCachedItem: Hashable{
    public let name: String
    public let ext: String
    public let localId: String
    public let localPath: String
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(localId)
    }
}
