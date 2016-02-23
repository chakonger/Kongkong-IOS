//
//  HomeTableViewCell.m
//  Control
//
//  Created by lvjianxiong on 15/1/20.
//  Copyright (c) 2015年 lvjianxiong. All rights reserved.
//

#import "HomeTableViewCell.h"
//#import "TelevisionView.h"
#import "UIColor+ZYHex.h"
//#import "AirView.h"

#import "CommonTool.h"
#import "UniteDevicesItem.h"
#import "UIImageView+WebCache.h"

#define kHomeHeadSize   40

@interface HomeTableViewCell (){
    UIImageView         *_headImageView;
    UILabel             *_nicknameLabel;
}
@property (nonatomic,strong)UniteDevicesItemDB *UnDevItemDB;
@end

@implementation HomeTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, kHomeHeadSize, kHomeHeadSize)];
        [self.contentView addSubview:_headImageView];
        
        CGFloat startX = CGRectGetMaxX(_headImageView.frame)+10;
        _nicknameLabel = [[UILabel alloc] initWithFrame:CGRectMake( startX, 10, [UIScreen mainScreen].applicationFrame.size.width-startX-10, kHomeHeadSize)];
        _nicknameLabel.textColor = [UIColor colorForHex:@"333333"];
        _nicknameLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        [self.contentView addSubview:_nicknameLabel];
        
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}
-(UniteDevicesItemDB *)UnDevItemDB
{
    if (!_UnDevItemDB) {
        _UnDevItemDB = [[UniteDevicesItemDB alloc]init];
        [_UnDevItemDB initManagedObjectContext];
    }
    return _UnDevItemDB;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGRect frame = self.frame;
    self.frame = frame;
}
/*
{
    DevStatus = A002;
    bigType = KG;
    brand = "";
    devID = 311410225506711;
    devName = "\U65b0\U63d2\U63a76711";
    devType = "\U63d2\U5ea7";
    infraName = "";
    lastInst =     {
        actionID = 0;
        exeTime = 0;
        inst = "";
        sender = 10102;
        upTime = 20150102152750;
    };
}
*/
- (void)setHomeContent:(DeviceItemVO *)vo{
  

    NSString *name = vo.deviceName;
    
    NSString *devStatus = vo.devStatus;
    
    NSString *devID = vo.devID;
    _nicknameLabel.text = name;
    
    
    
    //记录选中设备的Icon
    NSString *CacheKey = [NSString stringWithFormat:@"%@%@",devID,[[NSUserDefaults standardUserDefaults] objectForKey:@"sessionID"]];
    NSString *devTypeIDString =  [self getCache:CacheKey andID:3];
    if (devTypeIDString) {
        [self sendMseAction:devID With:devTypeIDString And:devStatus];
    }else
    {

        UniteDevicesItemVO *itemvo  = [[self.UnDevItemDB getAllMsgAction:devID] firstObject];
        
        
        [self sendMseAction:devID With:itemvo.devTypeID And:devStatus];
        
    }
}

//筛选图片
-(void)sendMseAction:(NSString *)devID With:(NSString *)devTypeID And:(NSString *)devStatus
{
    NSString *value = @"";
     NSString *logsetStr  = [self.UnDevItemDB getMseAction:devID With:devTypeID];
    
    if(logsetStr.length == 0)
    {
        value = @"mydevice_chazuo";
        if (nil!=devStatus) {
            if([@"A002" isEqualToString:devStatus]){
                //            value = [NSString stringWithFormat:@"%@_unwork",value];
                value = [NSString stringWithFormat:@"%@_off",value];
            }else if([@"A003" isEqualToString:devStatus]){
                value = [NSString stringWithFormat:@"%@_n",value];
            }
        }
        
        
        
        _headImageView.image = [UIImage imageNamed:value];
        
    }else{
        
        NSDictionary *logdict = [CommonTool dictionaryWithJsonString:logsetStr];
        NSString *URLstr = @"";
        
        
        
        if (nil!=devStatus) {
            if([@"A002" isEqualToString:devStatus]){
                URLstr = [NSString stringWithFormat:@"http://180.150.187.99/%@",logdict[@"off"]];
            }else if([@"A003" isEqualToString:devStatus]){
                URLstr = [NSString stringWithFormat:@"http://180.150.187.99/%@",logdict[@"onl"]];
            }else if([@"A004" isEqualToString:devStatus]){
                URLstr = [NSString stringWithFormat:@"http://180.150.187.99/%@",logdict[@"act"]];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_headImageView sd_setImageWithURL:[NSURL URLWithString:URLstr] placeholderImage:[UIImage imageNamed:@"control_blue"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
            }];
            
        });
        
    }
    
    
    
}






- (void)setFriendContent:(NSDictionary *)result{
    NSString *name = [result valueForKey:@"Name"];
    NSRange range = [name rangeOfString:@"@"];//判断字符串是否包含
    if (range.length>0) {
        name = [[name componentsSeparatedByString:@"@"] objectAtIndex:0];
    }
    _nicknameLabel.text = name;
    _headImageView.image = [result valueForKey:@"photo"];
}

- (NSString *)getCache:(NSString *)parmastring andID:(int)_id
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"detail-%@-%d",parmastring, _id];
    
    NSString *value = [settings objectForKey:key];
    return value;
}


@end
