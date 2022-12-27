//
//  MTDeviceOrientation.swift
//  MTPower
//
//

import Foundation

/*
    iPhone Orientation:Portrait

 func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
    return MTDeviceOrientation.allowedOrientation
 }
 */

struct MTDeviceOrientation {
    public static var allowedOrientation: UIInterfaceOrientationMask = .portrait
    
    public static func rotateHrizontal(){
        MTDeviceOrientation.allowedOrientation = .landscapeRight
        UIDevice.current.setValue(3, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }
    
    public static func rotateVertical(){
        MTDeviceOrientation.allowedOrientation = .portrait
        UIDevice.current.setValue(1, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }
    
    public static func rotateToggle(){
        if MTDeviceOrientation.allowedOrientation == .portrait{
            rotateHrizontal()
        }else{
            rotateVertical()
        }
    }
}
