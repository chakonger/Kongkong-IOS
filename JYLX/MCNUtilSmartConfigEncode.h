//
//  MCNUtilSmartConfigEncode.h
//  LN
//
//  Created by mcntek on 6/15/15.
//  Copyright (c) 2015 LN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCNUtilSmartConfigEncode : NSObject

+ (NSData *) buildConfigPacketWithSSID:(NSData *) ssid key:(NSString *) key IP:(NSString *)ip;

@end
