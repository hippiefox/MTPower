//
//  NSData_Ext.h
//  MTPower
//
//  Created by PanGu on 2022/10/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (WCS_ETAG)
- (NSString *)wcs_etag;

- (UInt32)commonCrc32;


/// 对字节进行xor处理
/// - Parameter data: 原始data
+ (NSData *)mtp_xor:(NSData *)data;

@end


NS_ASSUME_NONNULL_END
