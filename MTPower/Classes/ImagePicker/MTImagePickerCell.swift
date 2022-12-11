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
    
    public lazy var selectedImageView: UIImageView = {
        let view = UIImageView()
        view.image = MTImagePickerConfig.cellSelectedImage
        return view
    }()
    
    public lazy var videoImageView: UIImageView = {
        let view = UIImageView()
        view.image = MTImagePickerConfig.assetVideoImage
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    public lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = .white
        return label
    }()

    
    open var asset: PHAsset?{
        didSet{
            guard let asset = asset else{   return}
            loadPhotoIfNeeded()
            
            videoImageView.isHidden =  asset.duration > 0 ? false : true
            if asset.duration > 0{
                let d = Int(asset.duration)
                let dTimeStr = d.mt_2TimeFormat()
                durationLabel.text = dTimeStr
                durationLabel.isHidden = false
            }else{
                durationLabel.text = nil
                durationLabel.isHidden = true
            }
        }
    }
    
    open var isChoosed: Bool = false{
        didSet{
            selectedImageView.isHidden = !isChoosed
        }
    }

    public var __requestID: PHImageRequestID?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { $0.edges.equalToSuperview()}
        selectedImageView.isHidden = true
        contentView.addSubview(selectedImageView)
        selectedImageView.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 22, height: 22))
            $0.top.equalTo(8)
            $0.right.equalToSuperview().offset(-8)
        }
        videoImageView.isHidden = true
        contentView.addSubview(videoImageView)
        videoImageView.snp.makeConstraints {
            $0.width.height.equalTo(16)
            $0.left.equalTo((6))
            $0.bottom.equalToSuperview().offset((-6))
        }
        durationLabel.isHidden = true
        contentView.addSubview(durationLabel)
        durationLabel.snp.makeConstraints {
            $0.centerY.equalTo(videoImageView)
            $0.left.equalTo(videoImageView.snp.right).offset(2)
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
