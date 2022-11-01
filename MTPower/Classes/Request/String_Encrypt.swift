//
//  String_Encrypt.swift
//  MTPower
//
//  Created by PanGu on 2022/10/19.
//

import Foundation

extension String {
    public func mt_aes256_encryt() -> String? {
        guard let data = self.data(using: .utf8) as NSData? else { return nil }

        let cStr = cString(using: .utf8)
        let resultData = NSData(bytes: cStr, length: data.length)
        let encrypteStr = (resultData as Data).mt_aes256_encrypt()
        return encrypteStr
    }

    public func aes_256_decrypt() -> String? {
        if count < 20 { return nil }

        let key = (self as NSString).substring(to: 20)
        let content = (self as NSString).substring(from: 20)
        guard let data = Data(base64Encoded: content, options: .init(rawValue: 0)) else { return nil }

        let result = data.mt_aes256_decrypt(key)
        return result
    }
}
