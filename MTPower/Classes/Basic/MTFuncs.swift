//
//  MTFuncs.swift
//  MTPower
//
//

import Foundation

public func MTLog(_ items: Any...,
                  separator: String = " ",
                  terminator: String = "\n",
                  file: String = #file,
                  line: Int = #line,
                  method: String = #function)
{
    guard MTPowerConfig.default.isLogEnabled else { return }
    print("\n\((file as NSString).lastPathComponent) [\(line)] \(method)")
    print(items, separator: separator, terminator: terminator)
}

public func MTSize_storage(_ bytes: Int, unit: ByteCountFormatter.Units = .useAll, includesUnit: Bool = true) -> String {
    let format = ByteCountFormatter()
    format.allowedUnits = unit
    format.countStyle = .binary
    format.includesUnit = includesUnit
    return format.string(fromByteCount: .init(bytes))
}


