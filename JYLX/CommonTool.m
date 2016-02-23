//
//  CommonTool.m
//  JYLX
//
//  Created by ToTank on 16/2/1.
//  Copyright © 2016年 史志勇. All rights reserved.
//

#import "CommonTool.h"
#import <CommonCrypto/CommonDigest.h>
#import "DeviceItem.h"
#import "UniteDevicesItem.h"

@interface CommonTool()

@property (nonatomic,strong)DeviceItemDB *DevItemDB;
@property (nonatomic,strong)UniteDevicesItemDB *UniteDevDB;

@end

@implementation CommonTool

-(DeviceItemDB *)DevItemDB
{
    if (!_DevItemDB) {
        _DevItemDB = [[DeviceItemDB alloc]init];
        [_DevItemDB initManagedObjectContext];
    
    }
    return _DevItemDB;

}

-(UniteDevicesItemDB *)UniteDevDB
{
    if (!_UniteDevDB) {
        _UniteDevDB = [[UniteDevicesItemDB alloc]init];
        [_UniteDevDB initManagedObjectContext];
    }
    return _UniteDevDB;
}

+ (NSString *)md5ForString:(NSString *)strToEncode {
    
    const char *cStr = [strToEncode UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    
    NSString *r =  [NSString stringWithFormat:
                    @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                    //            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                    result[0], result[1], result[2], result[3],
                    result[4], result[5], result[6], result[7],
                    result[8], result[9], result[10], result[11],
                    result[12], result[13], result[14], result[15]
                    ];
    
    return r;
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

+ (NSString*)dictionaryToJson:(NSDictionary *)dic

{
    
    NSError *parseError = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
}
-(void)addFamilyToDB:(NSArray *)result{
    /*
     添加家人信息到数据库
     */
    
    NSMutableArray *deviceArray = [NSMutableArray array];
    for (NSDictionary *dict in result) {
        //除重复
        if ([self getDeviceToDB:dict]) {
         [self.DevItemDB removeDeviceByAction:[dict objectForKey:@"devID"]];
         [self.UniteDevDB removeAllUniteDeviceAction:[dict objectForKey:@"devID"]];
        }
        
        
        DeviceItemVO *vo = [[DeviceItemVO alloc] init];
        vo.devID = [dict valueForKey:@"devID"];
        vo.deviceName = [dict valueForKey:@"devName"];
        vo.devType = [[NSNull null] isEqual:[dict valueForKey:@"devType"]]?@"":[dict valueForKey:@"devType"];
        vo.devStatus = [dict valueForKey:@"devStatus"];
        vo.seed = [dict valueForKey:@"seed"];
        vo.token = [dict valueForKey:@"token"];
        NSString *lastInst = [dict valueForKey:@"lastInst"];
        vo.lastInst = lastInst;
        vo.bigType = [dict valueForKey:@"bigType"]==nil?@"KG":[dict valueForKey:@"bigType"];
        vo.brand = [dict valueForKey:@"brand"]==nil?@"":[dict valueForKey:@"brand"];
        vo.infraName = [dict valueForKey:@"infraName"]==nil?@"":[dict valueForKey:@"infraName"];
        [self AnalyzeJSon:dict[@"unitedevice"] with:[dict valueForKey:@"devID"]];
        
        vo.serialNumber = @"";
        vo.modelName = @"";
        vo.buyTime = @"";
        vo.infraTypeID = [dict valueForKey:@"infraTypeID"]== nil?@"":[dict valueForKey:@"infraTypeID"];
        vo.devTypeID = [dict valueForKey:@"devTypeID"]== nil?@"":[dict valueForKey:@"devTypeID"];
        [deviceArray addObject:vo];
        
    }
    [self.DevItemDB saveDeviceAction:deviceArray];
}

//支持的设备类型
-(void)AnalyzeJSon:(NSArray *)arr with:(NSString *)devID
{
    
    
    UniteDevicesItemVO *vo = [[self.UniteDevDB getAllMsgAction:devID] firstObject];
    if (vo == nil) {
        
        NSMutableArray *UniteDevicesArray = [NSMutableArray array];
        for (NSDictionary *dict in arr) {
            
            UniteDevicesItemVO *vo = [[UniteDevicesItemVO alloc] init];
            vo.infraTypeID = [dict[@"infraTypeID"] isEqual:[NSNull null]]?@"":dict[@"infraTypeID"];
            vo.infraName = (dict[@"infraName"] == nil)?@"":dict[@"infraName"] ;
            vo.devType = (dict[@"devType"] == nil)?@"":dict[@"devType"];
            vo.devTypeID = (dict[@"devTypeID"]== nil)?@"":dict[@"devTypeID"];
            vo.lastInst = (dict[@"lastInst"] == nil)?@"":dict[@"lastInst"];
            
            if ([dict[@"logoSet"] isEqualToDictionary:[NSDictionary dictionary]]) {
                vo.logoSet = @"";
            }
            else
            {
                vo.logoSet = [ self dictionaryToJson:dict[@"logoSet"]];
            }
            vo.bigType = (dict[@"bigType"] == nil)?@"":dict[@"bigType"];
            
            vo.subWeight = [dict[@"subWeight"]isEqual:[NSNull null]]?@"":dict[@"subWeight"];
            vo.panelType = (dict[@"panelType"]== nil)?@"":dict[@"panelType"];
            vo.devID = devID;
            [UniteDevicesArray addObject:vo];
        }
        [self.UniteDevDB saveUniteDeviceAction:UniteDevicesArray];
    }
}

-(NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}
-(NSString*)dictionaryToJson:(NSDictionary *)dic

{
    
    NSError *parseError = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
}
- (DeviceItemVO *)getDeviceToDB:(NSDictionary *)dict{
    NSString *devID = [dict valueForKey:@"devID"];
    DeviceItemDB *db = [[DeviceItemDB alloc] init];
    [db initManagedObjectContext];
    DeviceItemVO *vo = [db getDeviceAction:devID];
    return vo;
}

@end
