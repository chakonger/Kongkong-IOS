//
//  UniteDevicesItem.h
//  Control
//
//  Created by ToTank on 15/12/10.
//  Copyright © 2015年 lvjianxiong. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface UniteDevicesItem : NSManagedObject

@property (nonatomic, retain) NSString * infraTypeID;// 支持设备的红外ID
@property (nonatomic, retain) NSString * lastInst;//支持设备的最后一条指令
@property (nonatomic, retain) NSString * devType;//支持设备的类型（插座,空调等）
@property (nonatomic, retain) NSString * devID; //插座的唯一标示ID
@property (nonatomic, retain) NSString * devTypeID;//支持设备类型的ID（红外ID）（待确定）
@property (nonatomic, retain) NSString * panelType;// (暂时不用)
@property (nonatomic, retain) NSString * infraName;//红外类型
@property (nonatomic, retain) NSString * bigType; //支持设备的big类型

@property (nonatomic, retain) NSString * subWeight;//未知
@property (nonatomic, retain) NSString *logoSet; //图标（onl off act）

@end

@interface UniteDevicesItemVO : NSObject

@property (nonatomic, retain) NSString * infraTypeID;// 支持设备的红外ID
@property (nonatomic, retain) NSString * lastInst;//支持设备的最后一条指令
@property (nonatomic, retain) NSString * devType;//支持设备的类型（插座,空调等）
@property (nonatomic, retain) NSString * devID; //插座的唯一标示ID
@property (nonatomic, retain) NSString * devTypeID;//支持设备类型的ID（红外ID）（待确定）
@property (nonatomic, retain) NSString * panelType;// (暂时不用)
@property (nonatomic, retain) NSString * infraName;//红外类型
@property (nonatomic, retain) NSString * bigType; //支持设备的big类型

@property (nonatomic, retain) NSString * subWeight;//未知
@property (nonatomic, retain) NSString *logoSet; //图标（onl off act）

@end

@interface UniteDevicesItemDB : NSObject

@property (nonatomic, retain)NSManagedObjectContext *managedObjectContext;


//初始化列表
- (void )initManagedObjectContext;
//

//保存设备到本地
- (void)saveUniteDeviceAction:(NSArray *)deviceArray;


//添加设备到列表中
- (void)setMsgAction:(UniteDevicesItemVO *)vo;

//查询所有信息
- (NSMutableArray *)getAllMsgAction:(NSString *)devID;

//删除单个设备支持的设备
- (void)removeAllUniteDeviceAction:(NSString *)devID;
//查询单个支持设备
- (NSMutableArray *)getMsgAction:(NSString *)devID With:(NSString *)infraTypeID;
//查询单个设备的logset；
- (NSString *)getMseAction:(NSString *)devID With:(NSString *)devTypeID;


//更新
- (void)updateDeviceAction:(UniteDevicesItemVO *)vo;

//删除所有支持的设备
- (void)removeAllUniteDeviceAction;
//删除支持的单个设备
- (void)removeOneUniteDeviceAction:(NSString *)devID With:(NSString *)infraTypeID;


@end
