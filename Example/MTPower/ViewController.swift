//
//  ViewController.swift
//  MTPower
//
//  Created by HippieFox on 11/01/2022.
//  Copyright (c) 2022 HippieFox. All rights reserved.
//

import UIKit
import SnapKit
import MTPower

class ViewController: UIViewController {
    
    private lazy var button: MTSpringButton = {
        let btn = MTSpringButton()
        btn.titleNormal = "123"
        btn.titleSelected = "123456"
        btn.position = .top
        btn.contentInset = .init(top: 10, left: 10, bottom: 10, right: 10)
        btn.addTarget(self, action: #selector(tapMore), for: .touchUpInside)
        btn.backgroundColor = .gray
        return btn
    }()
    
    @objc private func tapMore(_ sender: UIControl){
        sender.isSelected = !sender.isSelected
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(button)
        button.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

