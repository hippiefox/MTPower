//
//  MTImagePickerView.swift
//  MTPower
//
//  Created by PanGu on 2022/11/3.
//

import Foundation
import Photos

open class MTImagePickerView: UIView {
    public var authFailedBlock: (()->Void)?
    public var choosingBlock:  ((Set<PHAsset>)->Void)?

    public lazy var collectionView: UICollectionView = {
        let layout = MTImagePickerConfig.layout(within: UIScreen.main.bounds.width)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MTImagePickerCell.self, forCellWithReuseIdentifier: "MTImagePickerCell")
        return collectionView
    }()

    private weak var relatedVC: UIViewController?
    public init(relatedVC: UIViewController) {
        super.init(frame: .zero)
        self.relatedVC = relatedVC
        addSubview(collectionView)
        collectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
        requestAccess()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    public var assets: [PHAsset] = []
    public var selectedAssets: Set<PHAsset> = []
    public func reloadUI(){
        self.collectionView.reloadData()
    }

    private func requestAccess() {
        MTPhotoAccess.request(from: relatedVC) { isAuthed in
            if isAuthed {
                self.fetchPhotos()
            } else {
                self.authFailedBlock?()
            }
        }
    }

    public lazy var fetchOptions: PHFetchOptions = {
        let opt = PHFetchOptions()
        opt.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return opt
    }()

    private func fetchPhotos() {
        MTImageFetcher.default.fetchAssets(to: MTImagePickerConfig.fetchPageSize)
        assets = MTImageFetcher.default.assets
        collectionView.reloadData()
    }

    private func fetchNextPageIfNeeded(indexPath: IndexPath) {
        // 触发到最后一个再去加载下一屏
        guard indexPath.item == assets.count - 1 else { return }

        let oldFetchLimit = assets.count
        let targetLimit = oldFetchLimit + MTImagePickerConfig.fetchPageSize
        MTImageFetcher.default.fetchAssets(to: targetLimit)
        assets = MTImageFetcher.default.assets
        var newIndexPaths: [IndexPath] = []
        for item in oldFetchLimit ..< assets.count {
            newIndexPaths.append(.init(item: item, section: 0))
        }
        collectionView.insertItems(at: newIndexPaths)
    }
    
    deinit {
        MTLog("------>deinit",self.classForCoder.description())
    }
}

extension MTImagePickerView: UICollectionViewDataSource {
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        assets.count
    }

    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fetchNextPageIfNeeded(indexPath: indexPath)
        let ast = assets[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MTImagePickerCell", for: indexPath) as! MTImagePickerCell
        cell.asset = ast
        cell.isChoosed = selectedAssets.contains(ast)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension MTImagePickerView: UICollectionViewDelegate {
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let ast = assets[indexPath.item]
        if let index = selectedAssets.firstIndex(of: ast){
            //删除
            selectedAssets.remove(at: index)
        }else{
            //插入
            selectedAssets.insert(ast)
        }
        collectionView.reloadData()
        choosingBlock?(selectedAssets)
    }
}
