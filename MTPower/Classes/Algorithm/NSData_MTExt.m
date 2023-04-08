//
//  NSData_Ext.m
//  MTPower
//
//  Created by PanGu on 2022/10/26.
//

#import "NSData_MTExt.h"

@implementation NSData (XOR)
+ (NSData *)mtp_xor:(NSData *)data{
    Byte * sourceDataPoint = (Byte *)[data bytes];
    for (long i = 0; i < data.length; i++) {
        sourceDataPoint[i] = sourceDataPoint[i] ^ 1;
    }
    return data;
}
@end
