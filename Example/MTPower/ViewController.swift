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
    
    private lazy var button: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .blue
        btn.addTarget(self, action: #selector(tapMore), for: .touchUpInside)
        return btn
    }()
    
    @objc private func tapMore(){
        let url = "https://cilihezi.cn/"
        let web = MTSearchWebController.init(urlString: url)
        self.navigationController?.pushViewController(web, animated: true)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(button)
        button.snp.makeConstraints {
            $0.width.height.equalTo(100)
            $0.center.equalToSuperview()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

