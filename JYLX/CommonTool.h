//
//  CommonTool.h
//  JYLX
//
//  Created by ToTank on 16/2/1.
//  Copyright © 2016年 史志勇. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonTool : NSObject

/*!
 @method
 @abstract MD5加密
 @param strToEncode 需要加密的字符串
 @return 返回一个MD5加密后字符串
 */
+ (NSString *)md5ForString:(NSString *)strToEncode;

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

+ (NSString*)dictionaryToJson:(NSDictionary *)dic;
-(void)addFamilyToDB:(NSArray *)result;

@end
