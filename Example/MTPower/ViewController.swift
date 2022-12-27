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
    
    private lazy var textView: MTPlaceholderTextView = {
        let view = MTPlaceholderTextView()
        MT_ViewBoarder(view, 1, .black)
        view.textLimit = 10
        view.placeholderText = "placeholder"
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(textView)
        textView.snp.makeConstraints {
            $0.left.equalTo(MT_Baseline(20))
            $0.right.equalToSuperview().offset(MT_Baseline(-20))
            $0.top.equalTo(MT_Baseline(100))
            $0.height.equalTo(200)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

