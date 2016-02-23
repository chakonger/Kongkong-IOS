//
//  ListViewController.h
//  JYLX
//
//  Created by ToTank on 16/2/1.
//  Copyright © 2016年 史志勇. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol JYLXMessageDelegate <NSObject>

-(void)getPushNewData:(NSDictionary *)message;

@end

@interface ListViewController : UIViewController
@property (nonatomic,strong)NSString *sessionID;


@property (nonatomic, weak)id<JYLXMessageDelegate> JylxMessageDelegate;

@end
