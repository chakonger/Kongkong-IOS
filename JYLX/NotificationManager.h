//
//  NotificationManager.h
//  ouser
//
//  Created by Liu Pingchuan on 13-3-29.
//  Copyright (c) 2013年 Totti.Lv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface NotificationManager : NSObject{
@private
    // The notificatin views array
    NSMutableArray *notificationQueue;
    
    // Are we showing a notification
    BOOL showingNotification;

}

+(NotificationManager *)sharedManager;

+(void)notificationWithMessage:(NSString *)message;

-(void)addNotificationViewWithMessage:(NSString *)message;
-(void)showNotificationView:(UIView *)notificationView;

@end
