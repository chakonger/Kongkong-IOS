//
//  RadarViewController.h
//  JYLX
//
//  Created by ToTank on 16/2/3.
//  Copyright © 2016年 史志勇. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol RadarDelegate <NSObject>

-(void)popToRootDelegate;

@end


@interface RadarViewController : UIViewController
@property (nonatomic, strong) NSString *wifiName;
@property (nonatomic, strong) NSString *wifiPwd;
@property (nonatomic,weak)id<RadarDelegate> delegate;
@end
