//
//  MTPropertyWrapper.swift
//  MTPower
//
//  Created by pulei yu on 2023/4/7.
//

import Foundation

@propertyWrapper
public struct MTUserDefaults<T>{
    public let key: String
    public let defaultValue: T
    
    public var wrappedValue: T{
        get{UserDefaults.standard.value(forKey: key) as? T ?? defaultValue}
        set{UserDefaults.standard.setValue(newValue, forKey: key)}
    }
    
    public init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
}

@propertyWrapper
public struct MTAssignOnce<T> {
    private var value: T?
    public var wrappedValue: T? {
        set {
            if value == nil {
                value = newValue
            }
        }
        get { value }
    }

    public init() {}
}
