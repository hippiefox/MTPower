//
//  Button_Ext.swift
//  MTPower
//
//  Created by PanGu on 2022/10/18.
//

import Foundation

public extension UIButton {
    convenience init(title: String, color: UIColor = .black, font: UIFont = .systemFont(ofSize: 16)) {
        self.init()
        setTitle(title, for: .normal)
        setTitleColor(color, for: .normal)
        titleLabel?.font = font
    }
}

public extension UIButton {
    @discardableResult
    func mt_rawCountDown(duration: Int = 60,
                         countingBlock: ((Int)->Void)? = nil,
                         completion: (()->Void)? = nil) -> DispatchSourceTimer {
        isEnabled = false

        let timeAtStart = Date().timeIntervalSince1970
        let ts = DispatchSource.makeTimerSource(flags: .init(rawValue: 0),
                                                queue: DispatchQueue.global())
        ts.schedule(deadline: .now(), repeating: .milliseconds(1000))
        ts.setEventHandler {
            DispatchQueue.main.async {
                let timeNow = Date().timeIntervalSince1970
                let leftTime = duration - Int(timeNow - timeAtStart)
                if leftTime < 0 {
                    ts.cancel()
                    self.isEnabled = true
                    self.setTitle("获取验证码", for: .normal)
                    completion?()
                } else {
                    self.setTitle("\(leftTime)s", for: .normal)
                    countingBlock?(leftTime)
                }
            }
        }
        ts.activate()
        return ts
    }
}

