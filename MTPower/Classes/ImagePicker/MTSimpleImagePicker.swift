//
//  MTImagePicker.swift
//  MTPower
//
//  Created by pulei yu on 2023/4/16.
//

import Foundation
import Photos
import UIKit



open class MTSimpleImagePicker: MTProtoViewController {
    public static func show(from controller: UIViewController,
                     of type: MTImageFetcher.AssetType,
                     limit: Int = 0,
                     min:Int = 0,
                     completion: @escaping MTValueBlock<Set<PHAsset>>) {
        MTImageFetcher.default.fetchAssetType = type
        let vc = MTSimpleImagePicker()
        vc.maxSelect = limit
        vc.minSelect = min
        vc.completionClosure = completion
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        controller.present(nav, animated: true)
    }

    public var maxSelect: Int = 0
    public var minSelect: Int = 0
    public var completionClosure: MTValueBlock<Set<PHAsset>>?

    public lazy var pickerView: MTImagePickerView = {
        let view = MTImagePickerView(relatedVC: self)
        view.choosingBlock = { [weak self] assets in
            self?.handleSelect(assets)
        }
        return view
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    public var selectedAssets: Set<PHAsset> = []
}

// MARK: - actions

extension MTSimpleImagePicker {
    public func handleSelect(_ assets: Set<PHAsset>) {
        mt_navigationBar?.title = MTImagePickerConfig.text_picker_selected + "(\(assets.count))"
        selectedAssets = assets
    }

    @objc public func tapCancel() {
        dismiss(animated: true)
    }

    @objc public func tapConfirm() {
        guard selectedAssets.count != 0 else {
            MTHUD.showText(MTImagePickerConfig.text_picker_tips)
            return
        }
        
        if minSelect > 0,
           selectedAssets.count < minSelect{
            MTHUD.showText(MTImagePickerConfig.text_picker_min+"(\(minSelect))")
            return
        }

        if maxSelect != 0,
           selectedAssets.count > maxSelect
        {
            MTHUD.showText(MTImagePickerConfig.text_picker_max+"(\(maxSelect))")
            return
        }

        dismiss(animated: true) {
            self.completionClosure?(self.selectedAssets)
        }
    }
}

// MARK: - UI

extension MTSimpleImagePicker {
    public func setupUI() {
        mt_navigationBar?.leftItem = .init(title: MTImagePickerConfig.text_picker_cancel, target: self, selector: #selector(tapCancel))
        mt_navigationBar?.rightItem = .init(title: MTImagePickerConfig.text_picker_confirm, target: self, selector: #selector(tapConfirm))
        mt_navigationBar?.title = MTImagePickerConfig.text_picker_title
        mt_navigationBar?.shadowColor = MT_COLOR(hex: "F5F5F5")!
        view.addSubview(pickerView)
        pickerView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.top.equalTo(mt_navigationBar!.snp.bottom).offset(MT_Baseline(15))
        }
    }
}
