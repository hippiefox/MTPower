//
//  MTProtoPlayControls.swift
//  MTPower
//
//  Created by Gogo on 2022/12/27.
//

import Foundation
import UIKit


public extension MTProtoPlayControls{
    enum Option {
        case play
        case pause
        case close
        case slideTo(Float)
        case sliding(Float)
        case longPress(Bool)
        case rotate
        case scale
        case softHard
        case lock(Bool)
        case doubleTap
        case rate
    }
    
    
}

open class MTProtoPlayControls: UIView{
    public var optionBlock: MTValueBlock<Option>?

}
