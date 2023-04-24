//
//  MTNetworkListener.swift
//  MTPower
//
//  Created by pulei yu on 2023/4/19.
//

import Foundation
import RealReachability

public extension MTNetworkListener{
    public enum Noti:String, MTNotiProtocol{
        case network_access
        
        public var name: String{rawValue}
    }
}

public class MTNetworkListener{
    public static let shared = MTNetworkListener()
    
    private(set) var lastNetworkStatus: ReachabilityStatus = .RealStatusUnknown
    
    public func listen(){
        guard let rr = RealReachability.sharedInstance() else { return }
        
        rr.startNotifier()
        lastNetworkStatus = rr.currentReachabilityStatus()
        NotificationCenter.default.addObserver(self, selector: #selector(notiNetworkChange(_:)), name: NSNotification.Name.realReachabilityChanged, object: nil)
    }
    
    @objc private func notiNetworkChange(_ noti: Notification){
        guard let reachability = noti.object as? RealReachability else { return }
        
        let newStatus = reachability.currentReachabilityStatus()
        if lastNetworkStatus == .RealStatusUnknown ||
            lastNetworkStatus == .RealStatusNotReachable
        {
            if newStatus == .RealStatusViaWWAN ||
                newStatus == .RealStatusViaWiFi
            {
                MTLog("------>network available")
                mt_noti(post: Noti.network_access)
            }
        }
        
        lastNetworkStatus = newStatus
        if case .RealStatusNotReachable = newStatus{
            MTLog("------>network failed")
        }
    }
}
