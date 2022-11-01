//
//  MTPlayerAlert_Ext.swift
//  MTPower
//
//  Created by PanGu on 2022/10/30.
//

import Foundation

public extension MTPlayerAlert {
    static func showSoftHard(from controller: UIViewController,
                             defaultOpt: MTPlayerConfig.SoftHardDecode,
                             completion: @escaping (MTPlayerConfig.SoftHardDecode) -> Void) {
        let alert = MTPlayerAlert<MTPlayerConfig.SoftHardDecode>.init(defaultOption: defaultOpt,
                                                                      options: MTPlayerConfig.SoftHardDecode.allCases,
                                                                      position: .bottom)
        alert.rotatedPosition = .right
        alert.optBlock = completion
        controller.present(alert, animated: true)
    }

    static func showRate(from controller: UIViewController,
                         defaultOpt: MTPlayerConfig.Rate,
                         completion: @escaping (MTPlayerConfig.Rate) -> Void) {
        let alert = MTPlayerAlert<MTPlayerConfig.Rate>.init(defaultOption: defaultOpt,
                                                            options: MTPlayerConfig.Rate.allCases,
                                                            position: .bottom)
        alert.optBlock = completion
        alert.rotatedPosition = .right
        controller.present(alert, animated: true)
    }

    static func showScale(from controller: UIViewController,
                          defaultOpt: MTPlayerConfig.Scale,
                          completion: @escaping (MTPlayerConfig.Scale) -> Void) {
        let alert = MTPlayerAlert<MTPlayerConfig.Scale>.init(defaultOption: defaultOpt,
                                                             options: MTPlayerConfig.Scale.allCases,
                                                             position: .bottom)
        alert.optBlock = completion
        alert.rotatedPosition = .right
        controller.present(alert, animated: true)
    }
}

extension MTPlayerConfig.Rate: MTPlayerAlertOption {
    public var title: String {
        "\(rawValue)×"
    }
}

extension MTPlayerConfig.Scale: MTPlayerAlertOption {
    public var title: String {
        switch self {
        case .default: return MTPlayerConfig.scaleDefaultString ?? ""
        case .fill: return MTPlayerConfig.scaleFillString ?? ""
        case .stretch: return MTPlayerConfig.scaleStretchString ?? ""
        }
    }
}

extension MTPlayerConfig.SoftHardDecode: MTPlayerAlertOption {
    public var title: String {
        switch self {
        case .soft: return MTPlayerConfig.softString ?? ""
        case .hard: return MTPlayerConfig.hardString ?? ""
        }
    }
}
