//
//  NotificationManager.m
//  ouser
//
//  Created by Liu Pingchuan on 13-3-29.
//  Copyright (c) 2013年 Totti.Lv. All rights reserved.
//

#import "NotificationManager.h"
//#import "Constant.h"

@implementation NotificationManager

#define kSecondsVisibleDelay 1.0f

+(NotificationManager *)sharedManager
{
    static NotificationManager *instance = nil;
    if(instance == nil) {
        instance = [[NotificationManager alloc] init];
    }
    return instance;
}

-(id)init
{
    if( (self = [super init]) ) {
        
        // Setup the array
        notificationQueue = [[NSMutableArray alloc] init];
        
        // Set not showing by default
        showingNotification = NO;
    }
    return self;
}

#pragma messages
+(void)notificationWithMessage:(NSString *)message
{
    // Show the notification
    [[NotificationManager sharedManager] addNotificationViewWithMessage:message];
}

-(void)addNotificationViewWithMessage:(NSString *)message
{
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    
    UIView *notificationView = [[UIView alloc] initWithFrame:CGRectMake(20, -44, [UIScreen mainScreen].applicationFrame.size.width-40, 54)];
    
    [notificationView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.8]];
    [[notificationView layer] setCornerRadius:5.0f];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, notificationView.frame.size.width-20, 49)];
    [label setText:message];
    [label setFont:[UIFont systemFontOfSize:14.0f]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:[UIColor whiteColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    [notificationView addSubview:label];
    
    [window addSubview:notificationView];
    [notificationQueue addObject:notificationView];
    
    if(!showingNotification) {
        [self showNotificationView:notificationView];
    }
}

-(void)showNotificationView:(UIView *)notificationView
{
    // Set showing the notification
    showingNotification = YES;
    
    // Animate the view downwards
    [UIView beginAnimations:@"" context:nil];
    
    // Setup a callback for the animation ended
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(showNotificationAnimationComplete:finished:context:)];
    
    [UIView setAnimationDuration:0.5f];
    
    [notificationView setFrame:CGRectMake(notificationView.frame.origin.x, notificationView.frame.origin.y+notificationView.frame.size.height, notificationView.frame.size.width, notificationView.frame.size.height)];
    
    [UIView commitAnimations];
}

-(void)showNotificationAnimationComplete:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context
{
    // Hide the notification after a set second delay
    [self performSelector:@selector(hideCurrentNotification) withObject:nil afterDelay:kSecondsVisibleDelay];
}

-(void)hideCurrentNotification
{
    // Get the current view
    UIView *notificationView = [notificationQueue objectAtIndex:0];
    
    // Animate the view downwards
    [UIView beginAnimations:@"" context:nil];
    
    // Setup a callback for the animation ended
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(hideNotificationAnimationComplete:finished:context:)];
    
    [UIView setAnimationDuration:0.5f];
    
    [notificationView setFrame:CGRectMake(notificationView.frame.origin.x, notificationView.frame.origin.y-notificationView.frame.size.height, notificationView.frame.size.width, notificationView.frame.size.height)];
    
    [UIView commitAnimations];
}

-(void)hideNotificationAnimationComplete:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context
{
    // Remove the old one
    UIView *notificationView = [notificationQueue objectAtIndex:0];
    [notificationView removeFromSuperview];
    [notificationQueue removeObject:notificationView];
    
    // Set not showing
    showingNotification = NO;
    
    // Do we have to add anymore items - if so show them
    if([notificationQueue count] > 0) {
        UIView *v = [notificationQueue objectAtIndex:0];
        [self showNotificationView:v];
    }
}


@end
