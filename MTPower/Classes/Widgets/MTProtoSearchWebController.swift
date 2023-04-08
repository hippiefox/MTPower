//
//  MTSearchWebController.swift
//  MTPower
//
//  Created by PanGu on 2022/11/2.
//

import Foundation
import WebKit

open class MTProtoSearchWebController: MTProtoWebViewController, WKNavigationDelegate{
    public var mgnscheme: String!
    public var ascheme: String!
    public var aschemeappkey: String!
    public var wscheme: String!
    public var appscheme: String!
    
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
    }
    
    open func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // load request that doesn't contain a targetFrame
        if navigationAction.targetFrame == nil{
            webView.load(navigationAction.request)
        }
        
        if let targetURL = navigationAction.request.url,
           let targetScheme = targetURL.scheme
        {
            if let mgnscheme = self.mgnscheme,
               mgnscheme == targetScheme
            {
                decisionHandler(.cancel)
                hdlmgn(targetURL.absoluteString)
                return
            }
            
            if let wscheme = self.wscheme,
               wscheme == targetScheme
            {
                decisionHandler(.cancel)
                hdlw(targetURL)
                return
            }
            
            var targetURLString = targetURL.absoluteString
            if let ascheme = self.ascheme,
               targetURLString.hasPrefix(ascheme)
            {
                if let aschemeappkey = self.aschemeappkey,
                   aschemeappkey.isEmpty == false,
                   let appscheme = self.appscheme
                {
                    targetURLString = String.mt_setQuery(apurl: targetURLString, key: aschemeappkey, value: appscheme)
                }
                decisionHandler(.cancel)
                hdla(targetURLString)
                return
            }
            
            if let appscheme = self.appscheme,
               appscheme == targetScheme
            {
                self.hdlapp(targetURLString)
            }
        }
        
        decisionHandler(.allow)
    }
    
    open func hdlmgn(_ urlString: String){
        MTLog(#function,urlString)
    }
    
    open func hdlw(_ url: URL){
        MTLog(#function,url)
        UIApplication.shared.open(url,options: [:],completionHandler: nil)
    }
    
    open func hdla(_ urlString: String){
        MTLog(#function,urlString)
        if let url = URL(string: urlString){
            UIApplication.shared.open(url,options: [:],completionHandler: nil)
        }
    }
    
    open func hdlapp(_ urlString: String){
        MTLog(#function,urlString)
    }
}


