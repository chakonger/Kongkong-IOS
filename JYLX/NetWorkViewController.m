//
//  NetWorkViewController.m
//  JYLX
//
//  Created by ToTank on 16/2/3.
//  Copyright © 2016年 史志勇. All rights reserved.
//

#import "NetWorkViewController.h"
#import "RadarViewController.h"
#import "NotificationManager.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@interface NetWorkViewController ()<RadarDelegate>

@property (nonatomic,strong)UITextField *wifipsd;
@property (nonatomic,strong)UITextField *wifiname;

@end

@implementation NetWorkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupBackBarButton];
    self.title = @"WIFI信息";
    [self setup];
    // Do any additional setup after loading the view.
}


-(void)setup
{
    NSString *currentSSID = @"";
    CFArrayRef myArray = CNCopySupportedInterfaces();
    if (myArray != nil){
        NSDictionary* myDict = (__bridge NSDictionary *) CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
        if (myDict!=nil){
            currentSSID=[myDict valueForKey:@"SSID"];
                       
        } else {
            currentSSID=@"<<NONE>>";
        }
    } else {
        currentSSID=@"<<NONE>>";
    }

    
    
    UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(10, self.view.frame.size.height/4,  100, 30)];
    name.text = @"WIFI名";
    name.textColor = [UIColor grayColor];
    
    _wifiname = [[UITextField alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(name.frame), self.view.frame.size.width - 20, 30)];
    _wifiname.text = currentSSID;
    _wifiname.placeholder = @"手机号哈 11位";
    _wifiname.returnKeyType = UIReturnKeyDefault;
    _wifiname.layer.masksToBounds = YES;
    _wifiname.layer.cornerRadius = 5.0f;
    _wifiname.layer.borderWidth = 0.5f;
    _wifiname.layer.borderColor = [UIColor grayColor].CGColor;
    
    [self.view addSubview:name];
    [self.view addSubview:_wifiname];
    
    UILabel *password = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(_wifiname.frame),  100, 30)];
    password.text = @"WIFI密码";
    password.textColor = [UIColor grayColor];
    
    _wifipsd = [[UITextField alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(password.frame), self.view.frame.size.width - 20, 30)];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *passText = ([defaults objectForKey:@"wifipsd"] == nil)?@"":[defaults objectForKey:@"wifipsd"];
    if (passText.length != 0) {
        _wifipsd.text = passText;
    }
    _wifipsd.placeholder = @"密码不支持特殊字符";
    _wifipsd.returnKeyType = UIReturnKeyDone;
    _wifipsd.layer.masksToBounds = YES;
    _wifipsd.layer.cornerRadius = 5.0f;
    _wifipsd.layer.borderWidth = 0.5f;
    _wifipsd.layer.borderColor = [UIColor grayColor].CGColor;
    
    [self.view addSubview:password];
    [self.view addSubview:_wifipsd];

   UIButton* _registBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(_wifipsd.frame)+30, self.view.frame.size.width - 20, 30)];
    [_registBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [_registBtn setBackgroundColor:[UIColor orangeColor]];
    _registBtn.layer.masksToBounds = YES;
    _registBtn.layer.cornerRadius = 5.0f;
    _registBtn.layer.borderWidth = 0.5f;
    _registBtn.layer.borderColor = [UIColor grayColor].CGColor;
    [_registBtn addTarget:self action:@selector(BangDingClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_registBtn];


}
-(void)BangDingClicked
{
    NSString *pwd = _wifipsd.text;
    if ([pwd stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length<=0) {
        [NotificationManager notificationWithMessage:@"密码不能为空"];
        return;
    }
    RadarViewController *radarView = [[RadarViewController alloc]init];
    radarView.delegate = self;
    radarView.wifiPwd = _wifipsd.text;
    radarView.wifiName = _wifiname.text;
    [self presentViewController:radarView animated:YES completion:nil];
    

    NSUserDefaults *defaul = [NSUserDefaults standardUserDefaults];
    
    [defaul setObject:_wifipsd.text forKey:@"wifipsd"];
    [defaul synchronize];

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)popToRootDelegate
{
    [self.navigationController popViewControllerAnimated:YES];

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

- (void)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
