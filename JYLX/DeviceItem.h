//
//  DeviceItem.h
//  Control
//
//  Created by kucababy on 15/2/28.
//  Copyright (c) 2015年 lvjianxiong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>



@interface DeviceItem : NSManagedObject

@property (nonatomic, retain) NSString * devType;
@property (nonatomic, retain) NSString * deviceName;
@property (nonatomic, retain) NSString * infraTypeID;
@property (nonatomic, retain) NSString * devStatus;
@property (nonatomic, retain) NSString * lastInst;
@property (nonatomic, retain) NSString * devID;
@property (nonatomic, retain) NSString * bigType;
@property (nonatomic, retain) NSString * brand;
@property (nonatomic, retain) NSString * infraName;
@property (nonatomic, retain) NSString * serialNumber;
@property (nonatomic, retain) NSString * modelName;
@property (nonatomic, retain) NSString * buyTime;
@property (nonatomic, retain) NSString * devTypeID;
@property (nonatomic, retain) NSString * token;
@property (nonatomic, retain) NSString * seed;

@end

@interface DeviceItemVO : NSObject

@property (nonatomic, retain) NSString * devType;
@property (nonatomic, retain) NSString * deviceName;
@property (nonatomic, retain) NSString *infraTypeID;
@property (nonatomic, retain) NSString * devStatus;
@property (nonatomic, retain) NSString * lastInst;
@property (nonatomic, retain) NSString * devID;
@property (nonatomic, retain) NSString * bigType;
@property (nonatomic, retain) NSString * brand;
@property (nonatomic, retain) NSString * infraName;
@property (nonatomic, retain) NSString * serialNumber;
@property (nonatomic, retain) NSString * modelName;
@property (nonatomic, retain) NSString * buyTime;
@property (nonatomic, retain) NSString * devTypeID;
@property (nonatomic, retain) NSString * token;
@property (nonatomic, retain) NSString * seed;


@end

@interface DeviceItemDB : NSObject
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void )initManagedObjectContext;

/*!
 保存数据到本地
 @property  vo
 */
- (void)saveDeviceAction:(NSArray *)deviceArray;

/*!
 获取本地缓存数据
 */
- (NSMutableArray *)getAllDeviceAction;

/*!
 获取设备名称信息
 */
- (DeviceItemVO *)getDeviceAction:(NSString *)devID;

/*!
 移除本地数据
 */
- (void)removeAllDeviceAction;

/*!
 移除特地的一条记录
 */
- (void)removeDeviceByAction:(NSString *)devID;
/*!
 修改本地数据
 @property  vo
 */
- (void)updateDeviceAction:(DeviceItemVO *)vo;

@end