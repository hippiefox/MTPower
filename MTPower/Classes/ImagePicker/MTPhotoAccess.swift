//
//  MTPhotoAccess.swift
//  MTPower
//
//  Created by PanGu on 2022/11/3.
//

import Foundation
import Photos

public struct MTPhotoAccess {
    public static var photoAuthString: String?
    public static var confirmString: String?
    public static var cancelString: String?
    
    public typealias MTPhotoAccessBlock = (Bool) -> Void

    public static func request(from controller: UIViewController?,
                        completion: @escaping MTPhotoAccessBlock) {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .restricted, .denied:
                    if let controller = controller {
                        self.authAlert(from: controller, completion:completion)
                    }
                case .authorized, .limited:
                    completion(true)
                default: break
                }
            }
        }
    }

    private static func authAlert(from controller: UIViewController,
                           completion: @escaping MTPhotoAccessBlock)
    {
        let ac = UIAlertController.init(title: MTPhotoAccess.photoAuthString, message: nil, preferredStyle: .alert)
        if let confirmString = MTPhotoAccess.confirmString{
            let action = UIAlertAction(title: confirmString, style: .default) { _ in
                UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
            }
            ac.addAction(action)
        }
        
        if let cancelString = MTPhotoAccess.cancelString{
            let action = UIAlertAction(title: cancelString, style: .default) { _ in
                completion(false)
            }
            ac.addAction(action)
        }
        controller.present(ac, animated: true)
    }
}

