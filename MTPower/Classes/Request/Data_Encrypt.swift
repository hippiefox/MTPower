//
//  Data_Encrypt.swift
//  MTPower
//
//  Created by PanGu on 2022/10/19.
//

import CommonCrypto
import Foundation
import GTMBase64

private let rawStr = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

extension Data {
    public func mt_aes256_encrypt() -> String? {
        let count = 20
        var salt = ""
        for _ in 0 ..< count {
            let random = arc4random_uniform(.init(rawStr.count))
            let char = (rawStr as NSString).character(at: Int(random))
            salt += String(format: "%C", char)
        }

        if salt.count != count {
            return nil
        }

        // 取前15位
        let keyStr = (salt as NSString).substring(to: 15)
        guard let keyData = keyStr.data(using: .utf8) as NSData? else {
            return nil
        }

        let digest = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(CC_SHA256_DIGEST_LENGTH))
        CC_SHA256(keyData.bytes, CC_LONG(keyData.length), digest)
        let ivStr = (salt as NSString).substring(from: 5)
        guard let ivData = ivStr.data(using: .utf8) as NSData? else {
            return nil
        }
        let ivdigest = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(CC_SHA256_DIGEST_LENGTH))
        CC_SHA256(ivData.bytes, CC_LONG(ivData.length), ivdigest)
        let dataLength = (self as NSData).length
        let bufferSize = dataLength + kCCBlockSizeAES128
        let buffer = malloc(bufferSize)
        var numberBytesEncrypt = 0
        let encryptResult = CCCrypt(CCOperation(kCCEncrypt),
                                    CCAlgorithm(kCCAlgorithmAES128),
                                    CCOptions(kCCOptionPKCS7Padding),
                                    digest,
                                    kCCKeySizeAES256,
                                    ivdigest,
                                    (self as NSData).bytes,
                                    dataLength,
                                    buffer,
                                    bufferSize,
                                    &numberBytesEncrypt)
        var resultStr: String?
        if encryptResult == kCCSuccess,
           let buffer = buffer {
            let resultData = NSData(bytesNoCopy: buffer, length: numberBytesEncrypt)
            if let _resultStr = GTMBase64.string(byEncoding: resultData as Data) {
                resultStr = salt + _resultStr
            }
        } else {
            free(buffer)
        }
        return resultStr
    }

    public func mt_aes256_decrypt(_ str: String) -> String? {
        if str.isEmpty == true {
            return nil
        }

        let keyStr = (str as NSString).substring(to: 15)
        guard let keyData = keyStr.data(using: .utf8) else {
            return nil
        }
        let digest = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(CC_SHA256_DIGEST_LENGTH))
        CC_SHA256((keyData as NSData).bytes, CC_LONG((keyData as NSData).length), digest)

        let ivStr = (str as NSString).substring(from: 5)
        guard let ivData = ivStr.data(using: .utf8) else {
            return nil
        }
        let ivdigest = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(CC_SHA256_DIGEST_LENGTH))
        CC_SHA256((ivData as NSData).bytes, CC_LONG((ivData as NSData).length), ivdigest)

        let dataLength = (self as NSData).length
        let bufferSize = dataLength + kCCBlockSizeAES128
        let buffer = malloc(bufferSize)
        var numberBytesDecrypt = 0
        let result = CCCrypt(CCOperation(kCCDecrypt),
                             CCAlgorithm(kCCAlgorithmAES128),
                             CCOptions(kCCOptionPKCS7Padding),
                             digest,
                             kCCKeySizeAES256,
                             ivdigest,
                             (self as NSData).bytes,
                             dataLength,
                             buffer,
                             bufferSize,
                             &numberBytesDecrypt)
        var resultStr: String?
        if result == kCCSuccess,
           let buffer = buffer {
            let resultData = NSData(bytesNoCopy: buffer, length: numberBytesDecrypt)
            let resStr = String(data: resultData as Data, encoding: .utf8)
            resultStr = resStr
        } else {
            free(buffer)
        }

        return resultStr
    }
}
