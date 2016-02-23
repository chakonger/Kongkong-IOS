//
//  ViewController.m
//  JYLX
//
//  Created by ToTank on 16/1/29.
//  Copyright © 2016年 史志勇. All rights reserved.
//

#define RegistUrl @"http://118.192.76.159:80/web/regist"
#define LoginUrl @"http://118.192.76.159:80/web/login"

#import "ViewController.h"
#import "ZYHttpTool.h"
#import "CommonTool.h"
#import "NotificationManager.h"
#import "ListViewController.h"
@interface ViewController ()
@property (nonatomic,strong)UIButton *registBtn;
@property (nonatomic,strong)UIButton *loginBtn;
@property (nonatomic,strong)UITextField *psdField;
@property (nonatomic,strong)UITextField *nameField;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"注册登录";
    [self setup];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
}




-(void)setup

{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(10, self.view.frame.size.height/4,  100, 30)];
    name.text = @"用户名";
    name.textColor = [UIColor grayColor];
    
    _nameField = [[UITextField alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(name.frame), self.view.frame.size.width - 20, 30)];
    NSString *nameText = ([defaults objectForKey:@"userName"] == nil)?@"":[defaults objectForKey:@"userName"];
    if (nameText.length != 0) {
        _nameField.text = nameText;
    }
    _nameField.placeholder = @"手机号哈 11位";
    _nameField.returnKeyType = UIReturnKeyDefault;
    _nameField.layer.masksToBounds = YES;
    _nameField.layer.cornerRadius = 5.0f;
    _nameField.layer.borderWidth = 0.5f;
    _nameField.layer.borderColor = [UIColor grayColor].CGColor;
    
    [self.view addSubview:name];
    [self.view addSubview:_nameField];
    
    UILabel *password = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(_nameField.frame),  100, 30)];
    password.text = @"用户密码";
    password.textColor = [UIColor grayColor];
    
    _psdField = [[UITextField alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(password.frame), self.view.frame.size.width - 20, 30)];
    NSString *passText = ([defaults objectForKey:@"passWord"] == nil)?@"":[defaults objectForKey:@"passWord"];
    if (passText.length != 0) {
        _psdField.text = passText;
    }
    _psdField.placeholder = @"密码为6-12位";
    _psdField.returnKeyType = UIReturnKeyDone;
    _psdField.layer.masksToBounds = YES;
    _psdField.layer.cornerRadius = 5.0f;
    _psdField.layer.borderWidth = 0.5f;
    _psdField.layer.borderColor = [UIColor grayColor].CGColor;
    
    [self.view addSubview:password];
    [self.view addSubview:_psdField];
    
    _registBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(_psdField.frame)+20, self.view.frame.size.width - 20, 40)];
    [_registBtn setTitle:@"注册" forState:UIControlStateNormal];
    [_registBtn setBackgroundColor:[UIColor orangeColor]];
    _registBtn.layer.masksToBounds = YES;
    _registBtn.layer.cornerRadius = 5.0f;
    _registBtn.layer.borderWidth = 0.5f;
    _registBtn.layer.borderColor = [UIColor grayColor].CGColor;
    [_registBtn addTarget:self action:@selector(registClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_registBtn];
    
    _loginBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(_registBtn.frame)+20, self.view.frame.size.width - 20, 40)];
    [_loginBtn setTitle:@"登陆" forState:UIControlStateNormal];
    [_loginBtn setBackgroundColor:[UIColor orangeColor]];
    _loginBtn.layer.masksToBounds = YES;
    _loginBtn.layer.cornerRadius = 5.0f;
    _loginBtn.layer.borderWidth = 0.5f;
    _loginBtn.layer.borderColor = [UIColor grayColor].CGColor;
    [_loginBtn addTarget:self action:@selector(loginClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_loginBtn];

    

}




-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

-(void)registClicked
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:_nameField.text forKey:@"userName"];
    [params setObject:[CommonTool md5ForString:_psdField.text ] forKey:@"passWord"];
    [params setObject:@"demo" forKey:@"appid"];
    [ZYHttpTool postWithURL:RegistUrl params:params success:^(id json) {
       
        if (![[json objectForKey:@"errmsg"] isEqualToString:@"0"]) {
            [_registBtn setTitle:@"注册失败" forState:UIControlStateNormal];
            [_registBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_registBtn setBackgroundColor:[UIColor redColor]];
            [NotificationManager notificationWithMessage:[json objectForKey:@"errmsg"]];
        }
        
    } failure:^(NSError *error) {
        NSLog(@"error %@",error);
        
    }];
    
    NSUserDefaults *defaul = [NSUserDefaults standardUserDefaults];
    [defaul setObject:_nameField.text forKey:@"userName"];
    [defaul setObject:_psdField.text forKey:@"passWord"];
    [defaul synchronize];

}

-(void)loginClicked
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:_nameField.text forKey:@"userName"];
    [params setObject:[CommonTool md5ForString:_psdField.text ] forKey:@"passWord"];

    [ZYHttpTool postWithURL:LoginUrl params:params success:^(id json) {
        if (![[NSString stringWithFormat:@"%@",[json objectForKey:@"errcode"]] isEqualToString:@"0"]) {
            [_loginBtn setTitle:@"登陆失败" forState:UIControlStateNormal];
            [_loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_loginBtn setBackgroundColor:[UIColor redColor]];
             [NotificationManager notificationWithMessage:[json objectForKey:@"errmsg"]];
            
        }
        else
        {
            ListViewController *list = [[ListViewController alloc]init];
            __weak ViewController *weakSelf = self;
            list.sessionID  = [json objectForKey:@"sessionID"];
            [weakSelf.navigationController pushViewController:list animated:YES];
        
        }
        
    } failure:^(NSError *error) {
        NSLog(@"error %@",error);
        
    }];

    NSUserDefaults *defaul = [NSUserDefaults standardUserDefaults];
    [defaul setObject:_nameField.text forKey:@"userName"];
    [defaul setObject:_psdField.text forKey:@"passWord"];
    [defaul synchronize];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
