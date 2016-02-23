//
//  HomeTableViewCell.h
//  Control
//
//  Created by lvjianxiong on 15/1/20.
//  Copyright (c) 2015年 lvjianxiong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceItem.h"

@interface HomeTableViewCell : UITableViewCell

/*
 设置设备内容
 @param result
 */
- (void)setHomeContent:(DeviceItemVO *)vo;

/*
 设置好友内容
 */
- (void)setFriendContent:(NSDictionary *)result;

@end
