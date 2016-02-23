    //
    //  MessageInputView.m
    //  WeiMi
    //
    //
    #define UnifiedOutletUrl   @"http://118.192.76.159:80/web/infratypeability"
    //

    #import "MessageInputView.h"

    #import "TelevisionView.h"
    #import "AircleanerView.h"
    #import "AirView.h"
    #import "UniversalView.h"
    #import "DeviceItem.h"
    #import "UniteDevicesItem.h"
    #import "UIImageView+WebCache.h"
    #import "CommonUtils.h"
    #import "UIColor+ZYHex.h"
    #import "ZYHttpTool.h"


    #define AirIconWidth 92

@interface MessageInputView () <UIPickerViewDataSource,UIPickerViewDelegate>{
    AirView         *_airView;
    TelevisionView  *_televisionView;
    AircleanerView  *_aircleanerView;
    UniversalView  *_universalView;
    BOOL            _isChat;//如果

    CGFloat Hight;
    CGFloat selfHight;
}


//@property (nonatomic, strong) UIButton* addButton;
//@property (nonatomic, strong) UIButton* emotionsButton;
//@property (nonatomic, strong) UIButton* sendButton;
@property (nonatomic, strong) UIView *lineV;



@property (nonatomic,strong)UIPickerView *PickerView;
@property (nonatomic,strong)NSMutableArray *pickerData;
@property (nonatomic, strong)DeviceItemVO *ItemVO;
@property (nonatomic,strong)NSString *DevID;
@property (nonatomic,strong)NSString *itemvobigType;
@property (nonatomic,strong) UniteDevicesItemDB *DB;




@end

@implementation MessageInputView

    - (id)initWithFrame:(CGRect)frame delegate:(id<MessageInputViewDelegate>)delegate withBigType:(DeviceItemVO *)bigType withIsChat:(BOOL)isChat
    {
    self.DevID = bigType.devID;
      self = [super initWithFrame:frame];
        selfHight  = frame.size.height;
    if(self) {
        _isChat = isChat;
        self.current_show_panel = 1;
        self.delegate = delegate;
       // self.textView = [[HPGrowingTextView alloc]init];
        [self setup:bigType];
       // self.backgroundColor = [UIColor colorForHex:BACKBROUND_B1];
        self.backgroundColor = [UIColor whiteColor];
        //self.textView.delegate = self;
        
        UIView *l = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 0.5f)];
        l.backgroundColor = [UIColor colorForHex:@"bebfc2"];
        [self addSubview:l];
        
        if(!_isChat){
        [self PostData:bigType.devID];
       //滑轮哈哈
        self.PickerView = [[UIPickerView alloc]init];
        self.PickerView.dataSource = self;
        self.PickerView.delegate = self;
        //self.PickerView.showsSelectionIndicator = YES;
        self.PickerView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.PickerView];
        }
        

    }
    return self;
    }

- (void)layoutSubviews
{
    //[self pickerView:self.PickerView didSelectRow:0 inComponent:0];
     NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    NSString *CacheKey = [NSString stringWithFormat:@"%@%@",self.DevID,userName];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *rowstr = [self getCache:CacheKey andID:2];
        if (rowstr == nil) {
            [self.PickerView selectRow:0 inComponent:0 animated:NO];
        }else{
            [self.PickerView selectRow:[rowstr integerValue] inComponent:0 animated:NO];
        }

        
    });
    CGFloat startY;
    if (Hight != 0) {
        startY = Hight;
    }else
    {
    startY = _isChat?0:kDeviceControlHeight;
    }
    
    if(!_isChat){
    ((UIView *)[self.PickerView.subviews objectAtIndex:1]).backgroundColor = [UIColor clearColor];
    ((UIView *)[self.PickerView.subviews objectAtIndex:2]).backgroundColor = [UIColor clearColor];
    
    if(CGRectGetMaxY([self.subviews objectAtIndex:2].frame)> kDeviceControlHeight)
    {
        self.PickerView.frame = CGRectMake(0,(CGRectGetMaxY(_universalView.frame)-kDeviceControlHeight)/2 , AirIconWidth, kDeviceControlHeight);
    }else
    {
       
            self.PickerView.frame = CGRectMake(0, 0, AirIconWidth, kDeviceControlHeight);
       
        
    }
        
        
  }
}
-(UniteDevicesItemDB*)DB
{
    if (!_DB) {
        _DB = [[UniteDevicesItemDB alloc]init];
        [_DB initManagedObjectContext];
    }
    return _DB;
}

- (void)dealloc
    {

    self.delegate = nil;
    }

- (void)setup:(DeviceItemVO *)bigType
    {
    //self.image = [UIImage inputBar];
    self.backgroundColor = [UIColor whiteColor];
    self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
    self.opaque = YES;
    self.userInteractionEnabled = YES;
    if (!_isChat) {
        if ([bigType.bigType isEqualToString:kDeviceBigTypeHW]) {
            [_televisionView removeFromSuperview];
            [self setupAirView];
        }else if ([bigType.bigType isEqualToString:kDeviceBigTypeKG]){
            [_aircleanerView removeFromSuperview];
            [self setupTelevisionView];
        }else {
           
            [_airView removeFromSuperview];
            //[self setupTelevisionView];
        }
    }
}

- (void)changeDevType:(DeviceItemVO *)bigType{

   
    
    
   
    UniteDevicesItemVO * itemVO = [[self.DB getMsgAction:bigType.devID With:bigType.infraTypeID] firstObject];
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[_aircleanerView class]] ||[view isKindOfClass:[_televisionView class]] || [view isKindOfClass:[_universalView class]] || [view isKindOfClass:[_airView class]]) {
            [view removeFromSuperview];
        }
    }
   [_televisionView removeFromSuperview];
   [_aircleanerView removeFromSuperview];
    if (_universalView) {
        [_universalView removeFromSuperview];
      //  CGFloat frameY = 0;
        
       
//        if (AppFrameHeight == 480) {
//            frameY = 272;
//        }else if(AppFrameHeight == 716)
//        {
//            frameY = 464;
//        }else if(AppFrameHeight == 647)
//            
//        {
//            frameY= 412;
//        }else{
//            frameY = 338;
//        
//        }
//        if ([bigType.devType isEqualToString:kDeviceBigTypeKG]||[bigType.devType isEqualToString:kDeviceBigTypeHW]) {
//            frameY = AppFrameHeight- kDeviceControlHeight;
//        }
//        
//        
//        self.frame = CGRectMake(0, frameY, AppFrameWidth, selfHight);
        
    }
    
    [_airView removeFromSuperview];
    if (!_isChat) {
        if ([itemVO.bigType isEqualToString:kDeviceBigTypeHW]) {
           
            [self setupAirView];
            _airView.infraTypeId =itemVO.infraTypeID;
            [_airView btnLastStateAction:itemVO.lastInst];
            
            Hight = 0;
            

        }else if([bigType.bigType isEqualToString:kDeviceBigTypeKG]){
            
            [self setupTelevisionView];
            [_televisionView btnLastOrderAction:itemVO.lastInst];
            
             Hight = 0;
        }
        
        else{
           
           
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            NSString *sessionID  =  [[NSUserDefaults standardUserDefaults] objectForKey:@"sessionID"];
            
            [dict setValue:sessionID forKey:@"sessionID"];
            [dict setValue:bigType.infraTypeID forKey:@"infraTypeID"];
             self.itemvobigType = bigType.bigType;
            NSString *CacheKey = [NSString stringWithFormat:@"%@,%@",bigType.devTypeID,bigType.infraTypeID];
           NSString * value = [self getCache:CacheKey andID:1];
            
            if (value == nil) {

                
               // NSLog(@"%@",json);
                
                [ZYHttpTool postWithURL: UnifiedOutletUrl params:dict success:^(id json) {
                    NSLog(@"%@",json);
                    
                    [self saveCache:CacheKey andID:1 andString:[CommonUtils dictionaryToJson:json]];
                    
                    NSDictionary *dic =[json objectForKey:@"infraTypeConfig"];
                    if([[json objectForKey:@"RTN"] isEqualToString:@"A9B2"])
                    {
                        
                    }else{
                        if (dic.count != 0 ) {
                            [self setupUniversalView:[json objectForKey:@"infraTypeConfig" ]];
                            
                            //通用面板的高度
                            
                            CGFloat fatH = [[[json objectForKey:@"infraTypeConfig"] objectForKey:@"keyRow"] floatValue];
                            if (fatH<2) {
                                fatH = 2;
                            }
                            Hight = fatH * KCustomButtonHight;
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                self.frame = CGRectMake(0, AppFrameHeight +20 -Hight , AppFrameWidth, Hight);
                                
                            });
                            
                        }
                    }

                    
                } failure:^(NSError *error) {
                    NSLog(@"++++----++++%@",error);
                }];
                
                   
                

                
                
                
            }else {
              NSDictionary *dic    =  [CommonUtils dictionaryWithJsonString:value];
               // NSDictionary *dic =[[CommonUtils dictionaryWithJsonString:value] objectForKey:@"infraTypeConfig"];
               // NSLog(@"+++++++%@",dic);
                if([[[CommonUtils dictionaryWithJsonString:value] objectForKey:@"RTN"] isEqualToString:@"A9B2"])
                {
                    
                }else{
                    if (dic.count != 0 ) {
                        [self setupUniversalView:[CommonUtils dictionaryWithJsonString:value]];
                        
                        //通用面板的高度
                        
                        CGFloat fatH = [[[CommonUtils dictionaryWithJsonString:value]  objectForKey:@"keyRow"] floatValue];
                        if (fatH<2) {
                            fatH = 2;
                        }
                        Hight = fatH * KCustomButtonHight;
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            self.frame = CGRectMake(0, AppFrameHeight +20 - Hight , AppFrameWidth, Hight);
                            
                        });
                        
                    }
                }

            
            
            }
            
            
            
            
        }
    }
}


    /*空调*/
    - (void)setupAirView{
    _airView = [[AirView alloc] initWithFrame:CGRectMake(AirIconWidth, 0, AppFrameWidth, kDeviceControlHeight)];
        
        
    [self addSubview:_airView];
    }

    /*插座*/
    - (void)setupTelevisionView{
    _televisionView = [[TelevisionView alloc] initWithFrame:CGRectMake( AirIconWidth, 0, AppFrameWidth, kDeviceControlHeight)];
        self.frame = CGRectMake(0, AppFrameHeight+20 -INPUT_HEIGHT , AppFrameWidth, selfHight);
    [self addSubview:_televisionView];
    }

    /*空气净化器*/
    - (void)setupAircleanerView{
    _aircleanerView = [[AircleanerView alloc] initWithFrame:CGRectMake(0, 0, AppFrameWidth, kDeviceControlHeight)];
        self.frame = CGRectMake(0, AppFrameHeight+20 -INPUT_HEIGHT , AppFrameWidth, selfHight);
    [self addSubview:_aircleanerView];
    }

    /*通用面板*/
    -(void)setupUniversalView:(NSDictionary *)dict
    {

    _universalView = [[UniversalView alloc] initWithDict:dict];

    [self addSubview:_universalView];
      //  NSLog(@"%@",self.subviews);

    }





-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
    {
    return 1;


    }

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    
      //  NSLog(@"self.pickerData.count%ld",self.pickerData.count);
    if(!_isChat){
      return self.pickerData.count;
    }else
    {
    
        return 0;
    }
}


    //选中某行干某事
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
    {
      //  [self.PickerView selectRow:2 inComponent:0 animated:NO];
     if(!_isChat){
    self.ItemVO = [[DeviceItemVO alloc]init];
    UniteDevicesItemVO *UniteDevicesItemVO = self.pickerData[row];
    self.ItemVO.bigType = UniteDevicesItemVO.bigType;
    self.ItemVO.lastInst = UniteDevicesItemVO.lastInst;
        
    self.ItemVO.devID= UniteDevicesItemVO.devID;
    self.ItemVO.infraName = UniteDevicesItemVO.infraName;
    self.ItemVO.infraTypeID = UniteDevicesItemVO.infraTypeID;
    self.ItemVO.devType = UniteDevicesItemVO.devType;
    self.ItemVO.devTypeID = UniteDevicesItemVO.devTypeID;
    //最后一条指令  kg？hw
      
    self.ItemVO.lastInst = UniteDevicesItemVO.lastInst;
        
    [self changeDevType:self.ItemVO];
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
         
    NSString *CacheKey = [NSString stringWithFormat:@"%@%@",self.ItemVO.devID,userName];
     //保存当前位置
    [self saveCache:CacheKey andID:2 andString:[NSString stringWithFormat:@"%ld",row]];
      //保存同步的图标icon
    [self saveCache:CacheKey andID:3 andString:self.ItemVO.devTypeID];
        
   
     [_delegate showBigTypePicker:self.ItemVO];
  }
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{

    return  60;
    }


-(UIView*) pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
    {
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 50, 50)];
      UIView *view2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 60)];
        
       
        UniteDevicesItemVO *ItemV0 = self.pickerData[row];
        
    if ([ItemV0.bigType isEqualToString:kDeviceBigTypeKG]) {
        imageView.image = _IMAGE(@"control_blue");
    }else if([ItemV0.bigType isEqualToString:kDeviceBigTypeHW])
    {
        imageView.image = _IMAGE(@"air_normal");
       
    }else
    {
        NSDictionary *dict = [CommonUtils dictionaryWithJsonString:ItemV0.logoSet];

        NSString *URLstr = [NSString stringWithFormat:@"http://180.150.187.99/%@",dict[@"onl"]];
        

        dispatch_async(dispatch_get_main_queue(), ^{
            
          [imageView sd_setImageWithURL:[NSURL URLWithString:URLstr] placeholderImage:_IMAGE(@"control_blue") completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
              
          }];
        
     });
}
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(65, 5, 30, 55)];
        label.text = ItemV0.infraName;
        label.numberOfLines = 0;
        label.font = _FONT(8);
        [view2 addSubview:imageView];
        [view2 addSubview:label];
       
       
    return view2;
    }

-(void)PostData:(NSString *)bigType
    {
        UniteDevicesItemDB *DB = [[UniteDevicesItemDB alloc]init];
        [DB initManagedObjectContext];
        self.pickerData = [DB getAllMsgAction:bigType];
        [self.PickerView reloadAllComponents];

        //让pickerview滚动到指定的某一行
       // [self.PickerView selectRow:1 inComponent:0 animated:NO];
            //模拟，通过代码选中某一行
         NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
        NSString *CacheKey = [NSString stringWithFormat:@"%@%@",bigType,userName];
        NSString *rowstr = [self getCache:CacheKey andID:2];
        if (rowstr == nil || (self.pickerData.count-1)<[rowstr integerValue]) {
            [self pickerView:self.PickerView didSelectRow:0 inComponent:0];
        }else{
        [self pickerView:self.PickerView didSelectRow:[rowstr integerValue] inComponent:0];
        }
        
}

- (void)saveCache:(NSString *)parmastring andID:(int)_id andString:(NSString *)str;  {
    NSUserDefaults * setting = [NSUserDefaults  standardUserDefaults];
    NSString * key = [NSString stringWithFormat:@"detail-%@-%d",parmastring, _id];
    [setting setObject:str forKey:key];
    [setting synchronize];
}

- (NSString *)getCache:(NSString *)parmastring andID:(int)_id
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"detail-%@-%d",parmastring, _id];
    
    NSString *value = [settings objectForKey:key];
    return value;
}


@end
