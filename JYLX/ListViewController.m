//
//  ListViewController.m
//  JYLX
//
//  Created by ToTank on 16/2/1.
//  Copyright © 2016年 史志勇. All rights reserved.
//
#define DevidlistUrl @"http://ss1.chakonger.net.cn/web/devicelist"

#define  PushNewUrl  @"http://ss1.chakonger.net.cn/web/getpushaddress"

#define  HostNewUrl  @"http://ss1.chakonger.net.cn/web/getpushevent"

#import "ListViewController.h"
#import "RadarViewController.h"
#import "ChatViewController.h"
#import "ZYHttpTool.h"
#import "DeviceItem.h"
#import "UniteDevicesItem.h"
#import "CommonTool.h"
#import "HomeTableViewCell.h"
#import "NetWorkViewController.h"
#import "ASIHTTPRequest.h"


@interface ListViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *_devidArray;
    NSString *url;// get 的路径地址
    

}
@property (nonatomic,strong)UITableView *lsitView;
@property (nonatomic,strong)DeviceItemDB *ItemDB;
@property (nonatomic,strong)UniteDevicesItemDB *UniteDevItemDB;
@property (nonatomic,strong)ASIHTTPRequest *requests;
@property (nonatomic,assign)BOOL isQuit;

@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _devidArray = [NSMutableArray array];
    [self setuprightBarButton];
    [self setupBackBarButton];
    self.title = @"设备列表";
    self.isQuit = NO;
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.lsitView = [[UITableView alloc]initWithFrame:self.view.frame];
    self.lsitView.delegate = self;
    self.lsitView.dataSource = self;
    [self.view addSubview:self.lsitView];
    
    
    
   
}

-(DeviceItemDB*)ItemDB
{
    if (!_ItemDB) {
        _ItemDB = [[DeviceItemDB alloc]init];
        [_ItemDB initManagedObjectContext];
    }

    return _ItemDB;
}

-(UniteDevicesItemDB*)UniteDevItemDB
{
    if (!_UniteDevItemDB) {
        _UniteDevItemDB = [[UniteDevicesItemDB alloc]init];
        [_UniteDevItemDB initManagedObjectContext];
    }
    return _UniteDevItemDB;
    
}

//-(ASIHTTPRequest *)requests
//{
//    if (!_requests) {
//        NSURL *urlstr = [[NSURL alloc] initWithString:url];
//        _requests = [ ASIHTTPRequest requestWithURL :urlstr];
//        _requests.timeOutSeconds = 10; // 超时
//        
//        // 设定委托，委托自己实现异步请求方法
//        _requests.delegate = self;
//        [_requests startAsynchronous];
// 
//    }
//
//    return _requests;
//}

-(void)getHttpLong
{
    
    NSURL *urlstr = [[NSURL alloc] initWithString:url];
    self.requests = [ ASIHTTPRequest requestWithURL :urlstr];
    self.requests.timeOutSeconds = 10; // 超时
   
    // 设定委托，委托自己实现异步请求方法
    self.requests.delegate = self;
    // 开始异步请求
    
    [self.requests startAsynchronous];

    __weak ListViewController *weakSelf = self;
    [self.requests setCompletionBlock :^{
        
      

        [weakSelf hostNewAction];
      
    }];
    [self.requests setFailedBlock:^{
        if (self.isQuit == NO) {
        NSLog(@"_________+++++++++___________");
        [weakSelf getHttpLong];
        }
    }];

    

}
-(void)pushNewAction
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"sessionID"] forKey:@"sessionID"];
    
    [ZYHttpTool postWithURL:PushNewUrl params:params success:^(id json) {
       
        url = [json objectForKey:@"address"];
       
        [self getHttpLong];
    } failure:^(NSError *error) {
        
    }];
    
    
    
}


-(void)hostNewAction
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"sessionID"] forKey:@"sessionID"];
    
    [ZYHttpTool postWithURL:HostNewUrl params:params success:^(id json) {
       // NSLog(@"--------%@",json);
        NSString *errcode = [NSString stringWithFormat:@"%@",[json objectForKey:@"errcode"]];
        if ([errcode isEqualToString:@"0"]) {
            [self AnalyzeJsonWith:json];
        }
        
        
        
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
        
    }];
   


}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"sessionID"]!= nil){
        _devidArray = [self.ItemDB getAllDeviceAction];
        
        [self.lsitView reloadData];

    }
    else
    {
    
    [[NSUserDefaults standardUserDefaults] setObject:self.sessionID forKey:@"sessionID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:self.sessionID forKey:@"sessionID"];
    
    [ZYHttpTool postWithURL:DevidlistUrl params:params success:^(id json) {
       
        
        CommonTool  *tool = [[CommonTool alloc]init];
        [tool addFamilyToDB: [json objectForKey:@"device"]];
        _devidArray = [self.ItemDB getAllDeviceAction];
        
        [self.lsitView reloadData];
        
    } failure:^(NSError *error) {
        
    }];
        
       
   
    }
    
    
   [self pushNewAction];
    
}



-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //一个数值
    return _devidArray.count;

}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *HomeCellIdentifier = @"HemeCell";

    HomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HomeCellIdentifier];
    if (cell == nil) {
        cell = [[HomeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:HomeCellIdentifier];
    }

    DeviceItemVO *itemVO = _devidArray[indexPath.row];
    [cell setHomeContent:itemVO];

    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return 60;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES ];

    DeviceItemVO *vo = _devidArray[indexPath.row];
    ChatViewController *chat = [[ChatViewController alloc]init];
    self.JylxMessageDelegate = chat;
    chat.deviceItem = vo;
    chat.isChat = NO;
    
    [self.navigationController pushViewController:chat animated:YES];

}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//对json 进行解析
-(void)AnalyzeJsonWith:(NSDictionary *)json
{
    NSArray *eventArray = [json objectForKey:@"event"];
    
    if (eventArray.count != 0) {
        if (self.isQuit == NO){
        [self getHttpLong];
        }
        for (NSDictionary *dict in eventArray) {
        
            [self pushNotificationWith:dict];
            
        }
    }else
    {
        if (self.isQuit == NO){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self getHttpLong];
            NSLog(@"2s+++++++--------++++++++");

        });
        
        
        }
     
    
    }


}

-(void)pushNotificationWith:(NSDictionary *)dict
{
    
    NSString *CMD = [NSString stringWithFormat:@"%@",[dict objectForKey:@"CMD"]];
    NSLog(@"cmd%@",CMD);
    NSLog(@"%@",dict);
    if ([CMD isEqualToString:@"N0A0"]||[CMD isEqualToString:@"N1A0"]) {
        NSLog(@"NOAO");
        //状态变更
        NSString *devID = [dict objectForKey:@"devID"];
        NSString *devStatus = [dict objectForKey:@"devStatus"];
        DeviceItemVO *VO = [self.ItemDB getDeviceAction:devID];
        VO.devStatus = devStatus;
        [self.ItemDB updateDeviceAction:VO];
        
        [_devidArray removeAllObjects];
        _devidArray = [self.ItemDB getAllDeviceAction];
        
        [self.lsitView reloadData];
        [_JylxMessageDelegate getPushNewData:dict];
        
        
    }else if([CMD isEqualToString:@"N6A0"]) {
      
        //新设备绑定成功
        //通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PushNewData" object:nil];
        
    }else if([CMD isEqualToString:@"N2A0"]) {
        
        
    }else if([CMD isEqualToString:@"N5A0"]) {
       
        NSString *bigType = [dict objectForKey:@"bigType"];
        NSString *devID = [dict objectForKey:@"devID"];
        NSString *infraTypeID = [dict objectForKey:@"infraTypeID"];
       UniteDevicesItemVO *VO  =  [[self.UniteDevItemDB getMsgAction:devID With:infraTypeID] firstObject];
        if ([bigType isEqualToString:kDeviceBigTypeKG]) {
            VO.lastInst =[dict objectForKey:@"actionID"];
        }else
        {
        VO.lastInst =[dict objectForKey:@"inst"];
        }
        [self.UniteDevItemDB updateDeviceAction:VO];
        [_JylxMessageDelegate getPushNewData:dict];

        
    }else if([CMD isEqualToString:@"N4A0"]) {
        NSLog(@"N4AO");
        
    }



}


- (void)setuprightBarButton
{
    UIImage *backNormalImage = [UIImage imageNamed:@"add_normal"];
    UIImage *backSelectedImage =[UIImage imageNamed:@"add_selected"];
    UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(-10, 0, backNormalImage.size.width, backNormalImage.size.height);
    [leftButton setImage:backNormalImage forState:UIControlStateNormal];
    [leftButton setImage:backSelectedImage forState:UIControlStateHighlighted];
    [leftButton setImage:backSelectedImage forState:UIControlStateSelected];
    [leftButton addTarget:self action:@selector(onMore:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.rightBarButtonItems = @[leftItem];
    self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
}

-(void)onMore:(UIButton *)btn
{
    NetWorkViewController *netView = [[NetWorkViewController alloc]init];
    [self.navigationController pushViewController:netView animated:YES];
    
}

-(void)dealloc
{
    NSLog(@"完全释放对象");

}

-(void)onBack:(UIButton *)btn
{

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"sessionID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.ItemDB removeAllDeviceAction];
    [self.UniteDevItemDB removeAllUniteDeviceAction];
    self.isQuit = YES;
    
    [self.navigationController popToRootViewControllerAnimated:YES];


}

- (void)setupBackBarButton
{
    UIImage *backNormalImage = [UIImage imageNamed:@"back_normal"];
    UIImage *backSelectedImage = [UIImage imageNamed:@"back_selected"];
    UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(-10, 0, backNormalImage.size.width, backNormalImage.size.height);
    [leftButton setImage:backNormalImage forState:UIControlStateNormal];
    [leftButton setImage:backSelectedImage forState:UIControlStateHighlighted];
    [leftButton setImage:backSelectedImage forState:UIControlStateSelected];
    [leftButton addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItems = @[leftItem];
}




@end
