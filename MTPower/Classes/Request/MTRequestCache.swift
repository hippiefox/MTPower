//
//  MTRequestCache.swift
//  MTPower
//
//  Created by PanGu on 2022/10/19.
//

import Foundation
import Cache
 
public struct MTReqCacheModel: Codable{
    var data: Data?
}

public class MTRequestCache{
    public static let `default` = MTRequestCache()
    
    private var diskStorage: DiskStorage<String,MTReqCacheModel>?
    
    public init(){
        let bid = MTDevice.bundleId
        let conf = DiskConfig(name: bid)
        let transform = TransformerFactory.forCodable(ofType: MTReqCacheModel.self)
        self.diskStorage = try? DiskStorage<String,MTReqCacheModel>(config: conf, transformer: transform)
    }
    
    public func removeAll(){
        try? self.diskStorage?.removeAll()
    }
    
    public func removeObject(for key: String){
        try? self.diskStorage?.removeObject(forKey: key)
    }
    
    public func object(for key: String)-> MTReqCacheModel?{
        if let result = try? diskStorage?.object(forKey: key){
            return result
        }
        return nil
    }
    
    public func setCache(value: MTReqCacheModel, for key: String){
        DispatchQueue.global().async {
            try? self.diskStorage?.setObject(value, forKey: key, expiry: nil)
        }
    }
}
