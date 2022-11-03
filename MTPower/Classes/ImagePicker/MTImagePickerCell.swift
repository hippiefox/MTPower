//
//  MTImagePickerCell.swift
//  MTPower
//
//  Created by PanGu on 2022/11/3.
//

import Foundation
import Photos
import SnapKit


open class MTImagePickerCell: UICollectionViewCell{
    public var deliveryMode: PHImageRequestOptionsDeliveryMode = .fastFormat
    public lazy var iconImageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    public lazy var selectedImage: UIImageView = {
        let view = UIImageView()
        view.image = MTImagePickerConfig.cellSelectedImage
        return view
    }()

    
    open var asset: PHAsset?{
        didSet{
            loadPhotoIfNeeded()
        }
    }
    
    open var isChoosed: Bool = false{
        didSet{
            selectedImage.isHidden = !isChoosed
        }
    }

    public var __requestID: PHImageRequestID?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { $0.edges.equalToSuperview()}
        selectedImage.isHidden = true
        contentView.addSubview(selectedImage)
        selectedImage.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 22, height: 22))
            $0.top.equalTo(8)
            $0.right.equalToSuperview().offset(-8)
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()

        iconImageView.image = nil
        let manager = PHImageManager.default()
        guard let reqId = __requestID else { return }
        manager.cancelImageRequest(reqId)
        __requestID = nil
    }
    
    open func loadPhotoIfNeeded(){
        guard let asset = asset else{   return}
        
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = self.deliveryMode
        options.resizeMode = .fast

        let aspectRatio = CGFloat(asset.pixelWidth) / CGFloat(asset.pixelHeight)
        var pxW = bounds.width * 2
        if aspectRatio > 1.8 { // 超宽
            pxW = pxW * aspectRatio
        }
        if aspectRatio < 0.2 {
            pxW = pxW * 0.5
        }

        let imageSize = CGSize(width: pxW, height: pxW / aspectRatio)

        __requestID = PHImageManager.default().requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFill, options: options) { [weak self] resultImg, _ in
            guard let self = self else { return }
            self.__requestID = nil
            self.iconImageView.image = resultImg
        }
    }
}
