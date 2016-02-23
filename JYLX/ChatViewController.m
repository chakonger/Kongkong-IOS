//
//  ChatViewController.m
//  JYLX
//
//  Created by ToTank on 16/2/17.
//  Copyright © 2016年 史志勇. All rights reserved.
// 聊天界面




#define RemoveDevidUrl  @"http://118.192.76.159:80/web/deviceremove"

#import "ChatViewController.h"
#import "ListViewController.h"
#import "ImageDataPickerViewController.h"
#import "DataPickerViewController.h"
#import "ZYCustomButton.h"
#import "SwitchView.h"
#import "CustomButton.h"
#import "MessageInputView.h"
#import "ChatMessageCell.h"
#import "ChatRecordItem.h"
#import "UniteDevicesItem.h"
#import "UIColor+ZYHex.h"
#import "UIMessageObject.h"
#import "UIImageView+WebCache.h"
#import "CommonUtils.h"
#import "ZYHttpTool.h"
#import "RightLayerView.h"




@interface ChatViewController ()<UITableViewDelegate,UITableViewDataSource,DataPickerViewControllerDelegate,ImageDataPickerViewControllerDelegate,MessageInputViewDelegate,JYLXMessageDelegate,RightLayerDelegate>
{
    
  MessageInputView                *_messageInputView;
    
  UITableView                     *_tableView;
  NSMutableArray                  *_messageArray;
  UIImage                         *_myAvatarImage;
  NSString                         *_itsAvatarImage;
   
  RightLayerView                  *_rightlayerView;

  ImageDataPickerViewController   *_modelPicker;
  DataPickerViewController        *_temperaturePicker;
  ImageDataPickerViewController   *_speedPicker;
  ImageDataPickerViewController   *_directionPicker;
    
    ZYCustomButton                  *_ZYCustonButton;
    SwitchView                      *_onoffSwitch;
    CustomButton                    *_modelBtn;
    CustomButton                    *_tmperatureBtn;
    CustomButton                    *_speedBtn;
    CustomButton                    *_directionBtn;
    
    //命令
    NSUInteger                      _onoffIndex;
    NSUInteger                      _modelIndex;
    NSUInteger                      _temperatureIndex;
    NSUInteger                      _speedIndex;
    NSUInteger                      _directionIndex;
    NSString                        *_chatContent;
}
@property(nonatomic,copy)NSString *sayStr;
@property (nonatomic,strong)NSTimer *timer;
@property (nonatomic, copy)NSString *DevidStatu;
@property (nonatomic, strong)ChatRecordDB *itemDB;
@property (nonatomic, strong)UniteDevicesItemDB *UnItemDB;
@property (nonatomic, strong)ChatRecordItemVO *vo;
@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.deviceItem.deviceName;
    self.view.backgroundColor = [UIColor whiteColor];
    
    _messageArray = [NSMutableArray array];
    _onoffIndex = 0;
    _modelIndex = 0;
    _temperatureIndex = 8;
    _speedIndex = 0;
    _directionIndex = 0;
    
    
    _modelPicker = [ImageDataPickerViewController alertControllerWithTitle:@"模式" message:@"\n\n\n\n\n\n\n\n\n\n\n" preferredStyle:UIAlertControllerStyleActionSheet];
    _modelPicker.tag = 1;
    _modelPicker.delegate = self;
    _modelPicker.dataArray = kModelArray;
    
    _temperaturePicker = [DataPickerViewController alertControllerWithTitle:@"温度" message:@"\n\n\n\n\n\n\n\n\n\n\n" preferredStyle:UIAlertControllerStyleActionSheet];
    _temperaturePicker.tag = 2;
    _temperaturePicker.delegate = self;
    _temperaturePicker.dataArray = kTemperatureArray;
    
    _speedPicker = [ImageDataPickerViewController alertControllerWithTitle:@"风速" message:@"\n\n\n\n\n\n\n\n\n\n\n" preferredStyle:UIAlertControllerStyleActionSheet];
    _speedPicker.tag = 3;
    _speedPicker.delegate = self;
    _speedPicker.dataArray = kSpeedArray;
    
    _directionPicker = [ImageDataPickerViewController alertControllerWithTitle:@"风向" message:@"\n\n\n\n\n\n\n\n\n\n\n" preferredStyle:UIAlertControllerStyleActionSheet];
    _directionPicker.tag = 4;
    _directionPicker.delegate = self;
    _directionPicker.dataArray = kDirectionArray;
    [self setupBackBarButton];
    [self  setupRemoveButton];
    [self setup];
    _rightlayerView = [[RightLayerView alloc] initWithFrame:CGRectMake(ViewControllerViewWidth-160, 60, 150, 57)];
    [_rightlayerView setRadiusTopLeft:4.0 topRight:4.0 bottomLeft:4.0 bottomRight:4.0];
    _rightlayerView.delegate = self;
    [self.view addSubview:_rightlayerView];
    
}

-(void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:YES];
    [_rightlayerView setHidden:YES];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMsgAction:) name:kYSShowGetMsgActionNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushControlAction:) name:kYSShowPushControlViewNotification object:nil];
    //定时
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushTimerAction:) name:kYSShowDatePickerNotification object:nil];
    //电量
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushPowerAction:) name:kYSShowSceneActionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchViewAction:) name:kYSShowOnOffSwitchNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showModelPicker:) name:kYSShowModelPickerNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTemperaturePicker:) name:kYSShowTemperatureNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSpeedPicker:) name:kYSShowSpeedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showDirectionPicker:) name:kYSShowDirectionNotification object:nil];
    
    /*
     通用面板指令
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendPustInstAction:) name:KYSShowPustInstUnivelNotification object:nil];

}
-(void)sendPustInstAction:(NSNotification *)notification
{
    _ZYCustonButton = (ZYCustomButton*)notification.object;
    if ([_ZYCustonButton.inst isEqualToString:@"timer"]) {
        //跳转到定时界面
        
        
    }else if([_ZYCustonButton.inst isEqualToString:@"meter"])
    {
        //跳转电量界面
        
        
    }else if ([_ZYCustonButton.type isEqualToString:@"url"])
    {
        //跳转到webView界面
       
        
    }else
    {
        //发送指令
        [self saveMsgAction:_ZYCustonButton.titleLabel.text withOrder:@"" withIsCome:@"1" withMsgType:MessageType_Text]; //存入数据库 发送内容
       // [self saveLastChatItem:_ZYCustonButton.titleLabel.text withOrder:@""]; //记录状态
        [self sendMsgAction:_ZYCustonButton.inst]; //发送内容
        [self getMsgAction:nil];
        
        
    }
    
    
}






-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    
    [self delRecordAction];
    
    

}





-(void)setup
{

    CGFloat cy = 40;
    CGRect tableFrame = CGRectMake(0.0f, cy, ViewControllerViewWidth, ViewControllerViewHeight - INPUT_HEIGHT -NAVIGATIONBAR_PLUS_STATUSBAR_HEIGHT - cy);
    _tableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    //    _tableView.editing = YES;
    _tableView.allowsMultipleSelectionDuringEditing = YES;

    [_tableView setBackgroundColor:[UIColor clearColor]];
    
    //[_tableView setBackgroundColor:[UIColor colorForHex:@"#e5e5e5"]];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"chatBg"]]];
    
    
    [self.view addSubview:_tableView];
    
    
    //实际隐藏tabBar;
    CGRect inputFrame = CGRectMake(0.0f, ViewControllerViewHeight-INPUT_HEIGHT, ViewControllerViewWidth, INPUT_HEIGHT);
    
    _messageInputView = [[MessageInputView alloc] initWithFrame:inputFrame delegate:self withBigType:self.deviceItem withIsChat:NO];
    [self.view addSubview:_messageInputView];

}



- (BubbleMessageType )messageTypeForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UIMessageObject *messageObject = [_messageArray objectAtIndex:indexPath.row];
    if(messageObject.sendOrRecv == MessageReceiveType_Send) {
        return BubbleMessageTypeOutgoing;
    }else {
        return BubbleMessageTypeIncoming;
    }
}

- (BOOL)shouldHaveTimestampForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UIMessageObject *m = [_messageArray objectAtIndex:indexPath.row];
    if (m && m.msgType == MessageType_Tips) {
        return NO;
    }
    
    if (m.displayTime && m.displayTime.length > 0) {
        return YES;
    }
    return NO;
}



#pragma mark- UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _messageArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UIMessageObject* message = [_messageArray objectAtIndex:indexPath.row];
    float height = [ChatMessageCell neededHeightForMessage:message
                                           messageCellType:[ChatMessageCell messageCellTypeForMessage:message]
                                                 timestamp:[self shouldHaveTimestampForRowAtIndexPath:indexPath]];
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    BubbleMessageType bubbleMessageType = [self messageTypeForRowAtIndexPath:indexPath];
    UIMessageObject* message = [_messageArray objectAtIndex:indexPath.row];
    BOOL hasTimestamp = [self shouldHaveTimestampForRowAtIndexPath:indexPath];
    ChatMessageCellType bubbleViewType = [ChatMessageCell messageCellTypeForMessage:message];
    
    NSString* CellID = [NSString stringWithFormat:@"MessageCell_%d_%d_%d", bubbleMessageType, hasTimestamp, bubbleViewType];
    ChatMessageCell* cell = (ChatMessageCell*)[tableView dequeueReusableCellWithIdentifier:CellID];
    if(!cell)
    {
        cell = [[ChatMessageCell alloc] initWithBubbleMessageType:bubbleMessageType
                                                     hasTimestamp:hasTimestamp
                                                   bubbleViewType:bubbleViewType
                                                         delegate:nil
                                                  reuseIdentifier:CellID];
        //        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    if (hasTimestamp) {
        [cell setTimestamp:message.displayTime];
    }
    if (message) {
        [cell setMessage:message];
        if ([message.iconName rangeOfString:@"http"].location != NSNotFound) {
            UIImageView * imageview = [[UIImageView alloc]init];
            [imageview sd_setImageWithURL:[NSURL URLWithString:message.iconName] placeholderImage:nil];
            
            [cell setAvatar:(bubbleMessageType == BubbleMessageTypeOutgoing) ? _myAvatarImage : imageview.image];
        }else{
            [cell setAvatar:(bubbleMessageType == BubbleMessageTypeOutgoing) ? _myAvatarImage : _IMAGE(message.iconName)];
        }

    }
    cell.bubbleView.delegate = nil;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


//懒加载
-(ChatRecordDB *)itemDB
{
    if (!_itemDB) {
        _itemDB = [[ChatRecordDB alloc]init];
        [_itemDB initManagedObjectContext];
    }
    
    return _itemDB;
}

//懒加载
-(UniteDevicesItemDB *)UnItemDB
{
    
    if (!_UnItemDB) {
        _UnItemDB = [[UniteDevicesItemDB alloc]init];
        [_UnItemDB initManagedObjectContext];
    }
    return _UnItemDB;
}
-(ChatRecordItemVO *)vo
{
    if (!_vo) {
        _vo = [[ChatRecordItemVO alloc]init];
        
    }
    return _vo;
    
}
//  开关发送命令
- (void)switchViewAction:(NSNotification *)notification{
    //空调开关 0，1
    //插座开关 0，2
    _onoffSwitch = (SwitchView *)notification.object;
    NSString *content = @"";
    NSString *order = @"";
    if ([self.deviceItem.bigType isEqualToString:kDeviceBigTypeHW]) {
        NSString *isOpen = @"0";
        if (_onoffSwitch.onoffBtn.selected) {
            isOpen = @"1";
            content = [NSString stringWithFormat:@"开_%@_%@℃_%@_%@",[kModelValueArray objectAtIndex:_modelIndex],[kTemperatureValueArray objectAtIndex:_temperatureIndex],[kSpeedValueArray objectAtIndex:_speedIndex],[kDirectionValueArray objectAtIndex:_directionIndex]];
        }else{
            isOpen = @"0";
            content = [NSString stringWithFormat:@"关_%@_%@℃_%@_%@",[kModelValueArray objectAtIndex:_modelIndex],[kTemperatureValueArray objectAtIndex:_temperatureIndex],[kSpeedValueArray objectAtIndex:_speedIndex],[kDirectionValueArray objectAtIndex:_directionIndex]];
        }
        
        order = [NSString stringWithFormat:@"%@%lu%@%lu%lu",isOpen,_modelIndex,[kTemperatureKeyArray objectAtIndex:_temperatureIndex],_speedIndex,_directionIndex];
    }else if ([self.deviceItem.bigType isEqualToString:kDeviceBigTypeKJ]) {
        if (_onoffSwitch.onoffBtn.selected) {
            order = @"T_ON";
            content = @"开";
        }else{
            order = @"T_OFF";
            content = @"关";
        }
    }else{
        NSString *isOpen = @"0";
        if (_onoffSwitch.onoffBtn.selected) {
            isOpen = @"2";
            content = @"开";
        }else{
            isOpen = @"0";
            content = @"关";
        }
        order = isOpen;
    }
    
    [self saveMsgAction:content withOrder:order withIsCome:@"1" withMsgType:MessageType_Text]; //存入数据库\ 发送内容
//    [self saveLastChatItem:content withOrder:order]; //记录状态
     [self sendMsgAction:order]; //发送内容
     [self getMsgAction:nil]; //聊天获取信息
}

- (void)showModelPicker:(NSNotification *)notification{
    _modelBtn = (CustomButton *)notification.object;
    
    [self presentViewController:_modelPicker animated:YES completion:nil];
    
}

- (void)showTemperaturePicker:(NSNotification *)notification{
    _tmperatureBtn = (CustomButton *)notification.object;
    
   [self presentViewController:_temperaturePicker animated:YES completion:nil];
   
}

- (void)showSpeedPicker:(NSNotification *)notification{
    _speedBtn = (CustomButton *)notification.object;
   
    [self presentViewController:_speedPicker animated:YES completion:nil];
    
}

- (void)showDirectionPicker:(NSNotification *)notification{
    _directionBtn = (CustomButton *)notification.object;
    
    [self presentViewController:_directionPicker animated:YES completion:nil];
}





//发送内容   等待回复
- (void)sendMsgAction:(NSString *)content{
    

    NSString *url = @"";
  
    if ([self.deviceItem.bigType isEqualToString:kDeviceBigTypeKG]) {
         url = [NSString stringWithFormat:@"http://118.192.76.159:80/web/action?actionID=%@&token=%@&infraTypeID=%@",content,self.deviceItem.token,self.deviceItem.infraTypeID];
    }else
    {
    url = [NSString stringWithFormat:@"http://118.192.76.159:80/web/action?actionID=%@&inst=%@&token=%@&infraTypeID=%@",@"6",content,self.deviceItem.token,self.deviceItem.infraTypeID];
       // NSLog(@"%@",self.deviceItem.infraTypeID);
       // NSLog(@"%@",url);
    
    }

    [ZYHttpTool getWithURL:url params:nil success:^(id json) {
        
       _chatContent = [json objectForKey:@"errmsg"];
       
       
        if ([_chatContent rangeOfString:@"无网络状态"].location != NSNotFound) {
            [self saveMsgAction:_chatContent withOrder:@"" withIsCome:@"0" withMsgType:MessageType_Text];
            [self getMsgAction:nil];
            _chatContent = nil;
        }
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
    
    
    
}


- (void)saveMsgAction:(NSString *)content withOrder:(NSString *)order withIsCome:(NSString *)isCome withMsgType:(NSInteger)msgtype{
     NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    NSString *time = [CommonUtils formatDate:@"yyyy-MM-dd HH:mm:ss" date:[NSDate date]];
    self.vo.uid = [NSNumber numberWithLongLong:[userName longLongValue]];
    self.vo.friendId = self.deviceItem.devID;
    self.vo.msgType  = [NSString stringWithFormat:@"%zd",msgtype];
    self.vo.msgTime = time;
    self.vo.mineMsg = @"";
    self.vo.friendMsg = content;
    self.vo.isComeMsg = isCome;
    self.vo.nativePath = @"";
    self.vo.saveTime = time;
    self.vo.voiceTime = time;
    self.vo.devTypeID = self.deviceItem.devTypeID;
    self.vo.time = [NSDate date];
    self.vo.order = order;
    self.vo.bigType = self.deviceItem.bigType;
    self.vo.devType = self.deviceItem.devType;
    [self.itemDB setMsgAction:self.vo];
    
}

- (void)getMsgAction:(id)sender{
    
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    [_messageArray removeAllObjects];
    
    NSString *friendId = self.deviceItem.devID;
    
    NSArray *chatArray = [self.itemDB getMsgAction:[NSNumber numberWithLongLong:[ userName longLongValue] ]withFriendId:friendId];
    
    for (ChatRecordItemVO *item in chatArray) {
        
        UIMessageObject *m = [[UIMessageObject alloc]init] ;
        m.content = item.friendMsg;
        m.time = time(0);
        m.devTypeID = item.devTypeID;
        m.msgType = item.msgType.integerValue;
        m.msgStatus = MessageStatus_Sending;
        m.displayTime = [CommonUtils formatDate:@"yyyy-MM-dd HH:mm:ss" date:item.time];
        if ([item.isComeMsg isEqualToString:@"1"]) {
            m.sendOrRecv = MessageReceiveType_Send;
            
                UIImage *image =_IMAGE(@"default_avatar");
                _myAvatarImage = image;

            
        }else{
            m.sendOrRecv = MessageReceiveType_Receive;
            NSString *devStatus = self.deviceItem.devStatus;
            NSString *value = [self IconNameWith:friendId typeWith:m.devTypeID AndDevStatus:devStatus];
            
            
            m.iconName = value;
            
        }
        
        m.chat_id = time(0);
        [_messageArray addObject:m];
        
    }
    [_tableView reloadData];
    
    
    
   
}



// 温度
#pragma mark- DataPickerViewControllerDelegate
- (void)pickViewDidSelectRowData:(NSInteger)selectedIndex withDataTag:(NSInteger)tag{
    _temperatureIndex = selectedIndex;
    NSString *value = [kTemperatureValueArray objectAtIndex:selectedIndex];
    value = [NSString stringWithFormat:@"%@℃",value];
    [_tmperatureBtn setTitle:value forState:UIControlStateNormal];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kYSShowOnOffChangeNotification object:[NSNumber numberWithInt:1]];
    NSString *content = [NSString stringWithFormat:@"开_%@_%@℃_%@_%@",[kModelValueArray objectAtIndex:_modelIndex],[kTemperatureValueArray objectAtIndex:_temperatureIndex],[kSpeedValueArray objectAtIndex:_speedIndex],[kDirectionValueArray objectAtIndex:_directionIndex]];
    NSString *order = [NSString stringWithFormat:@"1%lu%@%lu%lu",_modelIndex,[kTemperatureKeyArray objectAtIndex:_temperatureIndex],_speedIndex,_directionIndex];
    [self saveMsgAction:content withOrder:order withIsCome:@"1" withMsgType:MessageType_Text];

    [self sendMsgAction:order];
}

// 模式 风速 风向
#pragma mark- ImageDataPickerViewControllerDelegate
- (void)pickViewDidSelectRowData:(NSInteger)index withTag:(NSInteger)tag{
    switch (tag) {
        case 1:{
            [_modelBtn setImage:nil forState:UIControlStateNormal];
            [_modelBtn setImage:nil forState:UIControlStateSelected];
            [_modelBtn setImage:nil forState:UIControlStateHighlighted];
            [_modelBtn setTitle:nil forState:UIControlStateNormal];
            _modelIndex = index;
            NSString *value = [kModelValueArray objectAtIndex:index];
            UIImage *image = [kModelArray objectAtIndex:index];
            [_modelBtn setImage:image forState:UIControlStateNormal];
            [_modelBtn setImage:image forState:UIControlStateSelected];
            [_modelBtn setImage:image forState:UIControlStateHighlighted];
            [_modelBtn setTitle:value forState:UIControlStateNormal];
            break;
        }
        case 2:{
            
            _temperatureIndex = index;
            NSString *value = [kTemperatureValueArray objectAtIndex:_temperatureIndex];
            [_tmperatureBtn setTitle:value forState:UIControlStateNormal];
            break;
        }
        case 3:{
            [_speedBtn setImage:nil forState:UIControlStateNormal];
            [_speedBtn setImage:nil forState:UIControlStateSelected];
            [_speedBtn setImage:nil forState:UIControlStateHighlighted];
            [_speedBtn setTitle:nil forState:UIControlStateNormal];
            _speedIndex = index;
            NSString *value = [kSpeedValueArray objectAtIndex:index];
            UIImage *image = [kSpeedArray objectAtIndex:index];
            [_speedBtn setImage:image forState:UIControlStateNormal];
            [_speedBtn setImage:image forState:UIControlStateSelected];
            [_speedBtn setImage:image forState:UIControlStateHighlighted];
            [_speedBtn setTitle:value forState:UIControlStateNormal];
            break;
        }
        case 4:{
            [_directionBtn setImage:nil forState:UIControlStateNormal];
            [_directionBtn setImage:nil forState:UIControlStateSelected];
            [_directionBtn setImage:nil forState:UIControlStateHighlighted];
            [_directionBtn setTitle:nil forState:UIControlStateNormal];
            _directionIndex = index;
            NSString *value = [kDirectionValueArray objectAtIndex:index];
            UIImage *image = [kDirectionArray objectAtIndex:index];
            [_directionBtn setImage:image forState:UIControlStateNormal];
            [_directionBtn setImage:image forState:UIControlStateSelected];
            [_directionBtn setImage:image forState:UIControlStateHighlighted];
            [_directionBtn setTitle:value forState:UIControlStateNormal];
            break;
        }
        default:
            break;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kYSShowOnOffChangeNotification object:[NSNumber numberWithInt:1]];
    NSString *content = [NSString stringWithFormat:@"开_%@_%@℃_%@_%@",[kModelValueArray objectAtIndex:_modelIndex],[kTemperatureValueArray objectAtIndex:_temperatureIndex],[kSpeedValueArray objectAtIndex:_speedIndex],[kDirectionValueArray objectAtIndex:_directionIndex]];
    NSString *order = [NSString stringWithFormat:@"1%lu%@%lu%lu",_modelIndex,[kTemperatureKeyArray objectAtIndex:_temperatureIndex],_speedIndex,_directionIndex];
    [self saveMsgAction:content withOrder:order withIsCome:@"1" withMsgType:MessageType_Text];

    [self sendMsgAction:order];
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showBigTypePicker:(DeviceItemVO *)itemVO
{
    
    self.deviceItem.infraName = itemVO.infraName;
    self.deviceItem.infraTypeID = itemVO.infraTypeID;
    self.deviceItem.bigType = itemVO.bigType;
    self.deviceItem.devType = itemVO.devType;
    self.deviceItem.devTypeID = itemVO.devTypeID;
    [self parseOrder:itemVO.lastInst];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        _tableView.frame = CGRectMake(0, 0, ViewControllerViewWidth, _messageInputView.frame.origin.y);
    });
    
    [self deviceStateAction:nil withStatu:self.deviceItem.devStatus];
}
- (void)parseOrder:(NSString *)order{
    if (order.length==6) {
        NSString *modelOrder = [order substringWithRange:NSMakeRange(1, 1)];
        NSString *temperatureOrder = [order substringWithRange:NSMakeRange(2, 2)];
        NSString *speedOrder = [order substringWithRange:NSMakeRange(4, 1)];
        NSString *directionOrder = [order substringWithRange:NSMakeRange(5, 1)];
        NSUInteger modexIndex = [kModelKeyArray indexOfObject:modelOrder];
        NSUInteger temperatureIndex = [kTemperatureKeyArray indexOfObject:temperatureOrder];
        NSUInteger speedIndex = [kSpeedKeyArray indexOfObject:speedOrder];
        NSUInteger directionIndex = [kDirectionKeyArray indexOfObject:directionOrder];
        _modelIndex = (modexIndex==NSNotFound)?0:modexIndex;
        _temperatureIndex = (temperatureIndex==NSNotFound)?8:temperatureIndex;
        _speedIndex = (speedIndex==NSNotFound)?0:speedIndex;
        _directionIndex = (directionIndex==NSNotFound)?0:directionIndex;
    }
    
}
- (void)deviceStateAction:(NSString *)leval withStatu:(NSString *)statu{
    NSString *devID = self.deviceItem.devID;
    NSString *devTypeID = self.deviceItem.devTypeID;
    NSString *devStatus = statu;
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:devStatus forKey:@"devStatus"];
    [[NSNotificationCenter defaultCenter] postNotificationName:KYSShowIsOffEleNotification  object:nil userInfo:dict];
    
    NSString *value = [self IconNameWith:devID typeWith:devTypeID AndDevStatus:devStatus];
    
    
    _itsAvatarImage = value;
    
    [_tableView reloadData];
    // [[NSNotificationCenter defaultCenter] postNotificationName:kYSShowChangeDevImageNotification object:_itsAvatarImage];
}
-(NSString *)IconNameWith:(NSString *)devID  typeWith:(NSString *)devTypeID AndDevStatus:(NSString*)devStatus
{
    NSString *value = @"";
    NSString *logsetStr  = [self.UnItemDB getMseAction:devID With:devTypeID];
    if(logsetStr.length ==0)
    {
        value = @"mydevice_chazuo";
        if (nil!=devStatus) {
            if([kDeviceStatusA002 isEqualToString:devStatus]){
                //            value = [NSString stringWithFormat:@"%@_unwork",value];
                value = [NSString stringWithFormat:@"%@_off",value];
            }else if([kDeviceStatusA003 isEqualToString:devStatus]){
                value = [NSString stringWithFormat:@"%@_n",value];
            }
        }
        
        
        
        
    }else{
        
        
        NSDictionary *logdict = [CommonUtils dictionaryWithJsonString:logsetStr];
        if (nil!=devStatus) {
            if([kDeviceStatusA002 isEqualToString:devStatus]){
                value = [NSString stringWithFormat:@"http://180.150.187.99/%@",logdict[@"off"]];
            }else if([kDeviceStatusA003 isEqualToString:devStatus]){
                value = [NSString stringWithFormat:@"http://180.150.187.99/%@",logdict[@"onl"]];
            }else if([kDeviceStatusA004 isEqualToString:devStatus]){
                value = [NSString stringWithFormat:@"http://180.150.187.99/%@",logdict[@"act"]];
            }
        }
    }
    
    return value;
}

-(void)getPushNewData:(NSDictionary *)message
{
    NSString *CMD = [NSString stringWithFormat:@"%@",[message objectForKey:@"CMD"]];
    if ([CMD isEqualToString:@"N0A0"]||[CMD isEqualToString:@"N1A0"]) {
        
       NSString * devID = [NSString stringWithFormat:@"%@", [message objectForKey:@"devID"]];
       NSString * level = [message objectForKey:@"level"];
       NSString * devStatus = [message objectForKey:@"devStatus"];
        if ([self.deviceItem.devID isEqualToString:devID]) {
            [self deviceStateAction:level withStatu:devStatus];
        }
    }else
    {
        if(_chatContent != nil){
    [self saveMsgAction:_chatContent withOrder:@"" withIsCome:@"0" withMsgType:MessageType_Text];
    [self getMsgAction:nil];
        }
    _chatContent= nil;
    }


}


- (void)delRecordAction{
    //    removeMsgAction
         NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    ChatRecordDB *db = [[ChatRecordDB alloc] init];
    [db initManagedObjectContext];
    [db removeMsgAction:[NSNumber numberWithLongLong:[userName longLongValue]] withFriendId:self.deviceItem.devID];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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

- (void)setupRemoveButton
{
    UIImage *backNormalImage = [UIImage imageNamed:@"home_more"];
    UIImage *backSelectedImage = [UIImage imageNamed:@"home_more"];
    UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(-10, 0, backNormalImage.size.width, backNormalImage.size.height);
    [leftButton setImage:backNormalImage forState:UIControlStateNormal];
    [leftButton setImage:backSelectedImage forState:UIControlStateHighlighted];
    [leftButton setImage:backSelectedImage forState:UIControlStateSelected];
    [leftButton addTarget:self action:@selector(removeDived) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.rightBarButtonItems = @[leftItem];
}
-(void)removeDived
{
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.5;
    [_rightlayerView.layer addAnimation:animation forKey:nil];
    _rightlayerView.hidden = !_rightlayerView.hidden;


}

-(void)pushAboutViewController:(NSInteger)tag
{

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"sessionID"] forKey:@"sessionID"];
    [params setValue:self.deviceItem.devID forKey:@"devID"];
    
   [ZYHttpTool postWithURL:RemoveDevidUrl params:params success:^(id json) {
       [self delRecordAction];
       
       //删除设备
       DeviceItemDB *db = [[DeviceItemDB alloc]init];
       [db initManagedObjectContext];
       [db removeDeviceByAction:self.deviceItem.devID];
       
       [self.UnItemDB removeAllUniteDeviceAction:self.deviceItem.devID];
       NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
       
       NSString *CacheKey = [NSString stringWithFormat:@"%@%@",self.deviceItem.devID,userName];
       //保存当前位置
       [self RemoveCache:CacheKey andID:2];
       //保存同步的图标icon
       [self RemoveCache:CacheKey andID:3];
       
       [self onBack:nil];

       
       
   } failure:^(NSError *error) {
       NSLog(@"%@",error);
   }];
    
    
    
    

}
- (void)RemoveCache:(NSString *)parmastring andID:(int)_id
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"detail-%@-%d",parmastring, _id];
    
    [settings removeObjectForKey:key];
    [settings synchronize];
}



@end
