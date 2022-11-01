//
//  MTRequest.swift
//  MTPower
//
//  Created by PanGu on 2022/10/19.
//

import Foundation
import Moya

public struct MTHttpResponse {
    public let data: [AnyHashable: Any]
    public let isCache: Bool
}

public enum MTHttpError {
    case normal
    case networkError
    case parseError
    case decryptError
}

public typealias MTRequestCompletion = (_ result: MTResult<MTHttpResponse, MTHttpError>) -> Void

public class MTRequest<Target: MTTargetType> {
    public static func request(_ target: Target, completion: @escaping MTRequestCompletion) {
        let url = target.baseURL.absoluteString + target.path
        let urlCacheKey = MTRequestCacheKey.keyOf(url: url, params: target.params)

        // 读取缓存
        if target.cacheType == .onlyReadCache || target.cacheType == .requestCache {
            if let cachedData = MTRequestCache.default.object(for: urlCacheKey)?.data,
               let json = try? JSONSerialization.jsonObject(with: cachedData, options: []),
               let dic = json as? [AnyHashable: Any] {
                let resp = MTHttpResponse(data: dic, isCache: true)
                completion(.success(resp))
                if target.cacheType == .onlyReadCache {
                    return
                }
            }
        }

        MTRequest.provide(timeout: target.timeoutInterval).request(target) { result in
            switch result {
            case let .success(resp):
                guard let str = try? resp.mapString() else {
                    completion(.failure(.parseError))
                    return
                }

                var respStr = str
                // decrypt if resp is encrypted
                if target.isRespEncrypted {
                    guard let decryptedStr = str.aes_256_decrypt() else {
                        completion(.failure(.decryptError))
                        return
                    }
                    respStr = decryptedStr
                }
                respStr = respStr.trimmingCharacters(in: .controlCharacters)

                guard let jsonData = respStr.data(using: .utf8),
                      let _dic = try? JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed),
                      let dic = _dic as? [AnyHashable: Any]
                else {
                    completion(.failure(.parseError))
                    return
                }
                // cache result if needed
                if target.cacheType == .requestCache,
                   let data = try? JSONSerialization.data(withJSONObject: dic, options: .fragmentsAllowed)
                {
                    let cacheModel = MTReqCacheModel(data: data)
                    MTRequestCache.default.setCache(value: cacheModel, for: urlCacheKey)
                }
                // parse success without logic judgement
                completion(.success(.init(data: dic, isCache: false)))
            case let .failure(moyaError):
                if moyaError.errorCode == 6 {
                    completion(.failure(.networkError))
                } else {
                    completion(.failure(.normal))
                }
            }
        }
    }
}

extension MTRequest {
    private static func provide<Target: MTTargetType>(timeout: TimeInterval) -> MoyaProvider<Target> {
        let requestTimeoutClosure = { (endpoint: Endpoint, done: @escaping MoyaProvider<Target>.RequestResultClosure) in
            do {
                var request = try endpoint.urlRequest()
                request.timeoutInterval = timeout
                done(.success(request))
            } catch {
                done(.failure(MoyaError.underlying(MTError(), nil)))
                return
            }
        }
        let provider = MoyaProvider<Target>(requestClosure: requestTimeoutClosure)
        return provider
    }
}

private struct MTError: Error {}
