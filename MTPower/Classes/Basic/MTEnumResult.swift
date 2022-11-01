//
//  MTEnumResult.swift
//  MTPower
//
//  Created by PanGu on 2022/10/18.
//

import Foundation

public typealias MTValueBlock<Value> = (Value)->Void
public typealias MTNullBlock = ()->Void

public enum MTResult<Value0,Value1>{
    case success(Value0)
    case failure(Value1)
}

public enum MTNullResult{
    case success
    case failure
}

public enum MTValueResult<Value>{
    case success(Value)
    case failure(Value)
}

public enum MTSuccessResult<Value>{
    case success(Value)
    case failure
}

public enum MTErrorResult<Value>{
    case success
    case failure(Value)
}
