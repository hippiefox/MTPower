//
//  MTDownloadTask.swift
//  MTPower
//
//  Created by PanGu on 2022/11/3.
//

import Foundation
import RealmSwift

@objc public enum MTDownState: Int, RealmEnum, PersistableEnum {
    case none
    case waiting
    case ing
    case pause
    case success
    case failed
}


@objc public enum MTDMDownloadStep: Int, RealmEnum, PersistableEnum {
    case dming = 0
    case almost99
}


public class MTDownloadTask: Object {
    /*Basic*/
    @Persisted public var fid: String = ""
    @Persisted public var filename: String = ""
    @Persisted public var filesize: Int = 0
    /// group id
    @Persisted public var groupId: String = ""
    @Persisted public var timest: Int = Int(Date().timeIntervalSince1970 * 1000)
    @Persisted public var url: String = ""
    @Persisted public var otherInfo: String = ""
    
    /*CL*/
    @Persisted public var headerJSONStr: String  = ""
    @Persisted public var is_encrypted: Bool = false
    /// 40 bits character for b-t-i-h
    @Persisted public var etag: String = ""
    
    /*download progress*/
    @Persisted public var state: MTDownState = .none
    @Persisted public var downloadedSize: Int = 0
    @Persisted public var speedStr: String = ""
    
    
    /*DUMMYDOWN*/
    @Persisted public var isDM: Bool = false
    @Persisted public var dmStep: MTDMDownloadStep = .dming
    @Persisted public var dmAverageSpeed: Int = 0

    public override class func primaryKey() -> String? { "fid" }

    public var __needsFetchUrl: Bool { url.isEmpty == true }
    public var __iscl: Bool { etag.count == 40 }
}
