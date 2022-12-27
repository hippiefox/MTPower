//
//  MTFuncs.swift
//  MTPower
//
//

import Foundation

public func MTLog(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    guard MTPowerConfig.default.isLogEnabled else { return }
    print(items, separator: separator, terminator: terminator)
}

public func MTSize_storage(_ bytes: Int, unit: ByteCountFormatter.Units = .useAll, includesUnit: Bool = true) -> String {
    let format = ByteCountFormatter()
    format.allowedUnits = unit
    format.countStyle = .binary
    format.includesUnit = includesUnit
    return format.string(fromByteCount: .init(bytes))
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
