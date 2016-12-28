//
//  RadarViewController.m
//  JYLX
//
//  Created by ToTank on 16/2/3.
//  Copyright © 2016年 史志勇. All rights reserved.
//

#define  devicebindUrl @"http://ss1.chakonger.net.cn/web/devicebind"
#define  DevidlistUrl @"http://ss1.chakonger.net.cn/web/devicelist"
#define   SERVER_IP    @"ss1.chakonger.net.cn"


#import "RadarViewController.h"

#import "CommonTool.h"
#import "ZYHttpTool.h"

#import <AudioToolbox/AudioToolbox.h>

#import "GCDAsyncUdpSocket.h"
#import "UIColor+ZYHex.h"
#import "PulsingHaloLayer.h"
#import "ZYHttpTool.h"
#import "CJSONDeserializer.h"
#import "CJSONDataSerializer.h"
//樂新
#import "ESPTouchTask.h"
#import "ESPTouchResult.h"
#import "ESP_NetUtil.h"
#import "ESPTouchDelegate.h"
#import <SystemConfiguration/CaptiveNetwork.h>


@interface RadarViewController ()
{
    PulsingHaloLayer        *_halo;
    int                     _seed;
    
    UIImageView             *_bgImageView;
    UILabel                 *_phoneTipLabel;
    UIImageView             *_phoneDotImageView;    //手机点
    UIImageView             *_phoneLineImageView;   //手机线
    UIImageView             *_adaptDotImageView;    //插座点
    UIImageView             *_adaptLineImageView;   //插座线
    UIImageView             *_linkDotImageView;     //路由器点
    
    
    UIImageView             *_phoneHalfLineImageView;   //半条线
    UIImageView             *_adaptHalfLineImageView;   //
    
    UILabel                 *_phoneLabel;
    UILabel                 *_adaptLabel;
    UILabel                 *_linkLabel;
    
}

@property (strong, nonatomic) GCDAsyncUdpSocket *sendUdpSocket;
@property (strong, nonatomic) GCDAsyncUdpSocket *recvUdpSocket;

@property (atomic, strong) ESPTouchTask *_esptouchTask;
@property (nonatomic, strong) NSCondition *_condition;



@end

@implementation RadarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _seed = [self getRandomNumber:10000 to:65534];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getPostNewData) name:@"PushNewData" object:nil];
    
    [self setup];
}
-(void)setup
{
    
    _bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    
    _bgImageView.image = [UIImage imageNamed:@"device_bg"];
    _bgImageView.userInteractionEnabled = YES;
    [self.view addSubview:_bgImageView];
    CGFloat width = 100;
    
    /*
     关闭界面按钮
     */
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-width-10, 15, width, 30)];
    [closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.8] forState:UIControlStateNormal];
    [closeBtn.layer setMasksToBounds:YES];
    closeBtn.layer.borderColor = [UIColor colorForHex:@"f2f3f5"].CGColor;//;
    closeBtn.layer.borderWidth = 0.5;
    closeBtn.layer.cornerRadius = 3.0f;
    [closeBtn addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
    
    _phoneTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-130, self.view.frame.size.width, 30)];
    _phoneTipLabel.text = @"手机正在尝试连接云端";
    _phoneTipLabel.textAlignment =NSTextAlignmentCenter;
    _phoneTipLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    _phoneTipLabel.textColor = [UIColor whiteColor];
    [_bgImageView addSubview:_phoneTipLabel];
    
    CGFloat lineWidth = (self.view.frame.size.width-(30*3+40))/2;
    _phoneDotImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_phoneTipLabel.frame), 30, 30)];
    _phoneDotImageView.image = [UIImage imageNamed:@"device_yellow_dot"];
    [_bgImageView addSubview:_phoneDotImageView];
    
    _phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(_phoneDotImageView.frame),40, 20)];
    _phoneLabel.textAlignment = NSTextAlignmentCenter;
    _phoneLabel.text = @"手机";
    _phoneLabel.textColor = [UIColor whiteColor];
    _phoneLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    [_bgImageView addSubview:_phoneLabel];
    
    
    _phoneLineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_phoneDotImageView.frame), CGRectGetMaxY(_phoneTipLabel.frame)+11, lineWidth, 8)];
    _phoneLineImageView.image = [UIImage imageNamed:@"device_white_line"];
    [_bgImageView addSubview:_phoneLineImageView];
    
    _phoneHalfLineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_phoneDotImageView.frame), CGRectGetMaxY(_phoneTipLabel.frame)+11, lineWidth/2, 8)];
    _phoneHalfLineImageView.image = [UIImage imageNamed:@"device_yellow_line"];
    [_bgImageView addSubview:_phoneHalfLineImageView];
    
    
    
    _adaptDotImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_phoneLineImageView.frame), CGRectGetMinY(_phoneDotImageView.frame), 30, 30)];
    _adaptDotImageView.image = [UIImage imageNamed:@"device_white_dot"];
    [_bgImageView addSubview:_adaptDotImageView];
    
    _adaptLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_adaptDotImageView.frame)-5, CGRectGetMaxY(_adaptDotImageView.frame),40, 20)];
    _adaptLabel.textAlignment = NSTextAlignmentCenter;
    _adaptLabel.text = @"设备";
    _adaptLabel.textColor = [UIColor whiteColor];
    _adaptLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    [_bgImageView addSubview:_adaptLabel];
    
    
    _adaptLineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_adaptDotImageView.frame), CGRectGetMinY(_phoneLineImageView.frame), lineWidth, 8)];
    _adaptLineImageView.image = [UIImage imageNamed:@"device_white_line"];
    [_bgImageView addSubview:_adaptLineImageView];
    
    _adaptHalfLineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_adaptDotImageView.frame), CGRectGetMinY(_adaptLineImageView.frame), lineWidth/2, 8)];
    _adaptHalfLineImageView.image = [UIImage imageNamed:@"device_yellow_line"];
    [_bgImageView addSubview:_adaptHalfLineImageView];
    [_adaptHalfLineImageView setHidden:YES];
    
    _linkDotImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_adaptLineImageView.frame), CGRectGetMinY(_phoneDotImageView.frame), 30, 30)];
    _linkDotImageView.image = [UIImage imageNamed:@"device_white_dot"];
    [_bgImageView addSubview:_linkDotImageView];
    
    _linkLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_linkDotImageView.frame)-10, CGRectGetMaxY(_linkDotImageView.frame),50, 20)];
    _linkLabel.textAlignment = NSTextAlignmentCenter;
    _linkLabel.text = @"云端";
    _linkLabel.textColor = [UIColor whiteColor];
    _linkLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    [_bgImageView addSubview:_linkLabel];
    
    [self setupInitialValues];
    
    
    //开始绑定
    [self seedButtonClick];
    //启动监听
    NSError *error = nil;
    if (![self.recvUdpSocket beginReceiving:&error])
    {
        [self.recvUdpSocket close];
        
    }

}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [self.recvUdpSocket close];
    [self.sendUdpSocket close];



}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];


}



- (void)setupInitialValues{
    _halo = [PulsingHaloLayer layer];
    _halo.position = self.view.center;
    [self.view.layer insertSublayer:_halo above:self.view.layer];
    
    _halo.radius = 0.5 * (self.view.frame.size.width/2);
    _halo.backgroundColor = [UIColor colorWithRed:0.0
                                            green:0.487
                                             blue:1.0
                                            alpha:1.0].CGColor;
}

-(void)closeAction:(UIButton *)btn
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"fangqi" object:nil];
    
    

}

//绑定
-(void)seedButtonClick
{
    
    // 绑定设备
     //提交seed验证
    NSString *sessionID = [[NSUserDefaults standardUserDefaults] objectForKey:@"sessionID"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    
    [dict setValue:sessionID forKey:@"sessionID"];
    [dict setValue:@"demo" forKey:@"appid"];
    [dict setValue:[NSString stringWithFormat:@"%d",_seed] forKey:@"seed"];
    
    [ZYHttpTool postWithURL:devicebindUrl params:dict success:^(id json) {
       _phoneLineImageView.image =[UIImage imageNamed:@"device_yellow_line" ];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
              [self  executeForResult];//樂新绑定
            
        });

        
    } failure:^(NSError *error) {
       
    }];

    
    
    
    
    
}

- (ESPTouchResult *) executeForResult
{
    [self._condition lock];
    NSString *apSsid = self.wifiName;
    NSString *apPwd = self.wifiPwd;
    NSString *apBssid = [self fetchBssid];
    
    BOOL isSsidHidden = YES;
    self._esptouchTask =
    [[ESPTouchTask alloc]initWithApSsid:apSsid andApBssid:apBssid andApPwd:apPwd andIsSsidHiden:isSsidHidden];
    
    [self._condition unlock];
    ESPTouchResult * esptouchResult = [self._esptouchTask executeForResult];
    
    
    return esptouchResult;
}




- (GCDAsyncUdpSocket *) sendUdpSocket
{
    
    
    if(!_sendUdpSocket)
    {
        _sendUdpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        
        NSError *error = nil;
        
        if (![_sendUdpSocket enableBroadcast:YES error:&error])
        {
            // NSLog(@"Error binding: %@", error);
            _sendUdpSocket = nil;
        }
        if (![_sendUdpSocket bindToPort:0 error:&error])
        {
            //  NSLog(@"Error binding: %@", error);
            _sendUdpSocket = nil;
        }
    }
    return _sendUdpSocket;
}

#pragma mark- UDP
//用于接收UDP数据报的Socket
- (GCDAsyncUdpSocket *) recvUdpSocket
{
    NSLog(@"fafafafa");
    
    if(!_recvUdpSocket)
    {
        _recvUdpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        
        NSError *error = nil;
        
        if (![_recvUdpSocket bindToPort:7788 error:&error])
        {
            
            _recvUdpSocket = nil;
        }
    }
    return _recvUdpSocket;
}





- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    
    if (data != nil) {
        
        
        
            dispatch_async(dispatch_get_main_queue(), ^{
                _adaptDotImageView.image =[UIImage imageNamed:@"device_yellow_dot"]
                ;
                [_adaptHalfLineImageView setHidden:NO];
            });
            
        NSError *error = nil;
        NSString *host = nil;
        uint16_t port = 0;
        [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
        
        NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
        NSString *devSn = dict[@"devSn"];
        //发送服务器信息给插座
        
        
        NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:SERVER_IP,@"domain",@"80",@"port",[NSString stringWithFormat:@"%d",_seed],@"seed",devSn,@"devSn", nil];
        // NSLog(@"%@",param);
        NSData *jsonData = [[CJSONDataSerializer serializer] serializeDictionary:param];
        //json  转 data
        dispatch_async(dispatch_get_main_queue(), ^{
            _adaptLineImageView.image = [UIImage imageNamed:@"device_yellow_line"];
            _linkDotImageView.image = [UIImage imageNamed:@"device_yellow_dot"];
        });
        
       
        
        
        //查询family，看是否存在，如果存在，那么结束，如果不存在，那么继续进行发送数据
        [self.sendUdpSocket sendData:jsonData toHost:host port:port withTimeout:-1 tag:100000];
        
        }else{
            
            
            
    }
}

/*!
 生存随机数
 */
-(int)getRandomNumber:(int)from to:(int)to
{
    return (int)(from + (arc4random() % (to-from + 1)));
    
}

- (NSString *)fetchBssid
{
    NSDictionary *bssidInfo = [self fetchNetInfo];
    
    return [bssidInfo objectForKey:@"BSSID"];
}

// refer to http://stackoverflow.com/questions/5198716/iphone-get-ssid-without-private-library
- (NSDictionary *)fetchNetInfo
{
    NSArray *interfaceNames = CFBridgingRelease(CNCopySupportedInterfaces());
    //    NSLog(@"%s: Supported interfaces: %@", __func__, interfaceNames);
    
    NSDictionary *SSIDInfo;
    for (NSString *interfaceName in interfaceNames) {
        SSIDInfo = CFBridgingRelease(
                                     CNCopyCurrentNetworkInfo((__bridge CFStringRef)interfaceName));
        //        NSLog(@"%s: %@ => %@", __func__, interfaceName, SSIDInfo);
        
        BOOL isNotEmpty = (SSIDInfo.count > 0);
        if (isNotEmpty) {
            break;
        }
    }
    return SSIDInfo;
}


-(void)getPostNewData
{
    
  //发个通知给绑定  停止发送udp报文
  [[NSNotificationCenter defaultCenter]postNotificationName:@"fangqi" object:nil];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *sessionID = [[NSUserDefaults standardUserDefaults] objectForKey:@"sessionID"];
    [params setValue:sessionID forKey:@"sessionID"];
    [params setValue:@"" forKey:@"devicelist"];
    
    [ZYHttpTool postWithURL:DevidlistUrl params:params success:^(id json) {
        
        
        NSArray *deviceArray = [json objectForKey:@"device"];
        for (NSDictionary *dict in deviceArray) {
            if ([[dict objectForKey:@"seed"]integerValue] == _seed ) {
            CommonTool  *tool = [[CommonTool alloc]init];
            [tool addFamilyToDB: [json objectForKey:@"device"]];
            //退到列表页
            dispatch_async(dispatch_get_main_queue(), ^{
                [self AutoPopToViewController];
            });
                
                
            
    }
}
        
        
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
    


}

-(void)AutoPopToViewController
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);//震动效果
    [self dismissViewControllerAnimated:YES completion:nil];
    [_delegate popToRootDelegate];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
