//
//  ChatViewController.h
//  JYLX
//
//  Created by ToTank on 16/2/17.
//  Copyright © 2016年 史志勇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceItem.h"




@interface ChatViewController : UIViewController

@property (nonatomic, assign)BOOL isChat;

@property(nonatomic,strong)DeviceItemVO *deviceItem;

@end
