//
//  MTRefreshProtocol.swift
//  MTPower
//
//  Created by PanGu on 2022/10/19.
//

import Foundation
import MJRefresh

public protocol MTRefreshProtocol: UIViewController{
    var refreshScrollView: UIScrollView!{ get}
    
    func requestData(_ isRefresh: Bool)
    func addRefresh()
    func addLoadMore()
    func endRefresh()
}

public extension MTRefreshProtocol{
    func addRefresh(){
        refreshScrollView.mj_header = MJRefreshNormalHeader.init(refreshingBlock: { [weak self] in
            self?.requestData(true)
        })
    }
    
    func addLoadMore(){
        refreshScrollView.mj_footer = MJRefreshBackNormalFooter.init(refreshingBlock: { [weak self] in
            self?.requestData(false)
        })
    }
    
    func endRefresh(){
        self.refreshScrollView.mj_footer?.endRefreshing()
        self.refreshScrollView.mj_header?.endRefreshing()
    }
}

open class MTRefreshViewModel{
    public var isRefreshing = true
    public var offset: Int = 0
    
    public init(){}
}
