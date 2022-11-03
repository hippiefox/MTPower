//
//  MTSourceManager.swift
//  MTPower
//
//  Created by PanGu on 2022/11/2.
//

import Foundation
import Photos

public class MTSourceManager {
    public static let `default` = MTSourceManager()

    public let resourcesDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last! + "/MediaResources"
    public var resourcesPath: String { resourcesDirectory + "/Resources" }

    public func createDirectory() {
        try? FileManager.default.createDirectory(atPath: resourcesPath, withIntermediateDirectories: true, attributes: nil)
    }

    public func delete(filePath: String) {
        do {
            try FileManager.default.removeItem(atPath: filePath)
        } catch {
            MTLog(#function, "\(filePath) :::>failure")
        }
    }

    public func fetchAssetFilePath(asset: PHAsset, completion: @escaping (String?) -> Void) {
        asset.requestContentEditingInput(with: nil) { input, _ in
            var path = input?.fullSizeImageURL?.absoluteString
            if path == nil, let dir = asset.value(forKey: "directory") as? String, let name = asset.value(forKey: "filename") as? String {
                path = String(format: "file:///var/mobile/Media/%@/%@", dir, name)
            }
            completion(path)
        }
    }

    public func copyPhotosItemToSandbox(with assets: [PHAsset],
                                        completion: MTValueBlock<Set<MTSourceCachedItem>>? = nil)
    {
        let group = DispatchGroup()
        var cachedItems: Set<MTSourceCachedItem> = []
        let __resourcePath = resourcesPath

        for (idx, asset) in assets.enumerated() {
            group.enter()

            fetchAssetFilePath(asset: asset) { filePath in
                guard let filePath = filePath as NSString? else {
                    group.leave()
                    return
                }

                let pathExtension = filePath.pathExtension
                let fileName = (filePath.lastPathComponent as NSString).deletingPathExtension
                let directoryPath = __resourcePath
                let toPath = directoryPath + "/" + fileName + "." + pathExtension

                if FileManager.default.fileExists(atPath: toPath) {
                    // 表示文件已经存在沙盒，此时可以完成拷贝
                    let item = MTSourceCachedItem(name: fileName, ext: pathExtension, localId: asset.localIdentifier, localPath: toPath)
                    cachedItems.insert(item)
                    group.leave()
                    return
                }
                let fromPath = filePath.replacingOccurrences(of: "file://", with: "")
                do {
//                    let resourceName = fileName + "." + pathExtension
                    try FileManager.default.copyItem(atPath: fromPath, toPath: toPath)
                    let item = MTSourceCachedItem(name: fileName, ext: pathExtension, localId: asset.localIdentifier, localPath: toPath)
                    cachedItems.insert(item)
                    MTLog("写入沙盒 成功！！！！！")
                } catch {
                    MTLog("写入沙盒失败 ---- ，", error.localizedDescription)
                }
                group.leave()
            }
        }

        group.notify(queue: DispatchQueue.main) {
            MTLog("拷贝都完成了")
            completion?(cachedItems)
        }
    }
}
