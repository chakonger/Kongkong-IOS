//
//  ESPTouchTask.m
//  EspTouchDemo
//
//  Created by 白 桦 on 4/14/15.
//  Copyright (c) 2015 白 桦. All rights reserved.
//

//  The usage of NSCondition refer to: https://gist.github.com/prachigauriar/8118909

#import "ESPTouchTask.h"
#import "ESP_ByteUtil.h"
#import "ESPTouchGenerator.h"
#import "ESPUDPSocketClient.h"
#import "ESPUDPSocketServer.h"
#import "ESP_NetUtil.h"
#import "ESPTouchTaskParameter.h"
#import "GCDAsyncUdpSocket.h"
#import "MCNUtilSmartConfigEncode.h"
#import "CJSONDeserializer.h"
#import "CJSONDataSerializer.h"
#import <UIKit/UIApplication.h>

//ZY 获取IP地址
#include <arpa/inet.h>
#include <netdb.h>

#include <net/if.h>
#include <ifaddrs.h>
#import <dlfcn.h>


#define ONE_DATA_LEN    3

@interface ESPTouchTask ()

@property (nonatomic,strong) NSString *_apSsid;

@property (nonatomic,strong) NSString *_apBssid;

@property (nonatomic,strong) NSString *_apPwd;

@property (nonatomic,strong) NSString *ip;

@property (atomic,assign) BOOL _isSuc;

@property (atomic,assign) BOOL _isInterrupt;

@property (nonatomic,strong) ESPUDPSocketClient *_client;

@property (nonatomic,strong) ESPUDPSocketServer *_server;

@property (atomic,strong) NSMutableArray *_esptouchResultArray;

@property (atomic,strong) NSCondition *_condition;

@property (nonatomic,assign) __block BOOL _isWakeUp;

@property (nonatomic,assign) volatile BOOL _isExecutedAlready;

@property (nonatomic,assign) BOOL _isSsidHidden;

@property (nonatomic,strong) ESPTaskParameter *_parameter;

@property (atomic,strong) NSMutableDictionary *_bssidTaskSucCountDict;

@property (atomic,strong) NSCondition *_esptouchResultArrayCondition;

@property (nonatomic,assign) __block UIBackgroundTaskIdentifier _backgroundTask;

@property (nonatomic,strong) id<ESPTouchDelegate> _esptouchDelegate;

@property (strong, nonatomic) GCDAsyncUdpSocket *sendWifiUdpSocket;

//@property (strong, nonatomic) GCDAsyncUdpSocket *recvUdpSocket;

@property (assign, atomic) BOOL seedFlg;


@end

@implementation ESPTouchTask

- (id) initWithApSsid: (NSString *)apSsid andApBssid: (NSString *) apBssid andApPwd: (NSString *)apPwd andIsSsidHiden: (BOOL) isSsidHidden
{
    if (apSsid==nil||[apSsid isEqualToString:@""])
    {
        perror("ESPTouchTask initWithApSsid() apSsid shouldn't be null or empty");
    }
    // the apSsid should be null or empty
    assert(apSsid!=nil&&![apSsid isEqualToString:@""]);
    if (apPwd == nil)
    {
        apPwd = @"";
    }
    
    self = [super init];
    if (self)
    {
        if (DEBUG_ON)
        {
           // NSLog(@"ESPTouchTask init");
        }
        self._apSsid = apSsid;
        self._apPwd = apPwd;
        self._apBssid = apBssid;
        self._parameter = [[ESPTaskParameter alloc]init];
        self._client = [[ESPUDPSocketClient alloc]init];
        self._server = [[ESPUDPSocketServer alloc]initWithPort: [self._parameter getPortListening]
                                              AndSocketTimeout: [self._parameter getWaitUdpTotalMillisecond]];
        self._isSuc = NO;
        self._isInterrupt = NO;
        self._isWakeUp = NO;
        self._isExecutedAlready = NO;
        self._condition = [[NSCondition alloc]init];
        self._isSsidHidden = isSsidHidden;
        self._esptouchResultArray = [[NSMutableArray alloc]init];
        self._bssidTaskSucCountDict = [[NSMutableDictionary alloc]init];
        self._esptouchResultArrayCondition = [[NSCondition alloc]init];
        [self ZHUan];
        self.seedFlg = false;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendflgs) name:@"fangqi" object:nil];

    }
    return self;
}

- (id) initWithApSsid: (NSString *)apSsid andApBssid: (NSString *) apBssid andApPwd: (NSString *)apPwd andIsSsidHiden: (BOOL) isSsidHidden andTimeoutMillisecond: (int) timeoutMillisecond
{
    ESPTouchTask *_self = [self initWithApSsid:apSsid andApBssid:apBssid andApPwd:apPwd andIsSsidHiden:isSsidHidden];
    if (_self)
    {
        [_self._parameter setWaitUdpTotalMillisecond:timeoutMillisecond];
    }
    return _self;
}

- (void) __putEsptouchResultIsSuc: (BOOL) isSuc AndBssid: (NSString *)bssid AndInetAddr:(NSData *)inetAddr
{
    [self._esptouchResultArrayCondition lock];
    // check whether the result receive enough UDP response
    BOOL isTaskSucCountEnough = NO;
    NSNumber *countNumber = [self._bssidTaskSucCountDict objectForKey:bssid];
    int count = 0;
    if (countNumber != nil)
    {
        count = [countNumber intValue];
    }
    ++count;
    if (DEBUG_ON)
    {
       // NSLog(@"ESPTouchTask __putEsptouchResult(): count = %d",count);
    }
    countNumber = [[NSNumber alloc]initWithInt:count];
    [self._bssidTaskSucCountDict setObject:countNumber forKey:bssid];
    isTaskSucCountEnough = count >= [self._parameter getThresholdSucBroadcastCount];
    if (!isTaskSucCountEnough)
    {
        if (DEBUG_ON)
        {
           // NSLog(@"ESPTouchTask __putEsptouchResult(): count = %d, isn't enough", count);
        }
        [self._esptouchResultArrayCondition unlock];
        return;
    }
    // check whether the result is in the mEsptouchResultList already
    BOOL isExist = NO;
    for (id esptouchResultId in self._esptouchResultArray)
    {
        ESPTouchResult *esptouchResultInArray = esptouchResultId;
        if ([esptouchResultInArray.bssid isEqualToString:bssid])
        {
            isExist = YES;
            break;
        }
    }
    // only add the result who isn't in the mEsptouchResultList
    if (!isExist)
    {
        if (DEBUG_ON)
        {
            NSLog(@"ESPTouchTask __putEsptouchResult(): put one more result");
        }
        ESPTouchResult *esptouchResult = [[ESPTouchResult alloc]initWithIsSuc:isSuc andBssid:bssid andInetAddrData:inetAddr];
        [self._esptouchResultArray addObject:esptouchResult];
        if (self._esptouchDelegate != nil)
        {
            [self._esptouchDelegate onEsptouchResultAddedWithResult:esptouchResult];
        }
    }
    [self._esptouchResultArrayCondition unlock];
}

-(NSArray *) __getEsptouchResultList
{
    [self._esptouchResultArrayCondition lock];
    if ([self._esptouchResultArray count] == 0)
    {
        ESPTouchResult *esptouchResult = [[ESPTouchResult alloc]initWithIsSuc:NO andBssid:nil andInetAddrData:nil];
        esptouchResult.isCancelled = self.isCancelled;
        [self._esptouchResultArray addObject:esptouchResult];
    }
    [self._esptouchResultArrayCondition unlock];
    return self._esptouchResultArray;
}


- (void) beginBackgroundTask
{
    if (DEBUG_ON)
    {
        NSLog(@"ESPTouchTask beginBackgroundTask() entrance");
    }
    self._backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        if (DEBUG_ON)
        {
            NSLog(@"ESPTouchTask beginBackgroundTask() endBackgroundTask");
        }
        [self endBackgroundTask];
    }];
}

- (void) endBackgroundTask
{
    if (DEBUG_ON)
    {
        NSLog(@"ESPTouchTask endBackgroundTask() entrance");
    }
    [[UIApplication sharedApplication] endBackgroundTask: self._backgroundTask];
    self._backgroundTask = UIBackgroundTaskInvalid;
}

- (void) __listenAsyn: (const int) expectDataLen
{
    dispatch_queue_t  queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self beginBackgroundTask];
        if (DEBUG_ON)
        {
            NSLog(@"ESPTouchTask __listenAsyn() start an asyn listen task, current thread is: %@", [NSThread currentThread]);
        }
        NSTimeInterval startTimestamp = [[NSDate date] timeIntervalSince1970];
        NSString *apSsidAndPwd = [NSString stringWithFormat:@"%@%@",self._apSsid,self._apPwd];
        Byte expectOneByte = [ESP_ByteUtil getBytesByNSString:apSsidAndPwd].length + 9;
        if (DEBUG_ON)
        {
            NSLog(@"ESPTouchTask __listenAsyn() expectOneByte: %d",expectOneByte);
        }
        Byte receiveOneByte = -1;
        NSData *receiveData = nil;
        while ([self._esptouchResultArray count] < [self._parameter getExpectTaskResultCount] && !self._isInterrupt)
        {
            receiveData = [self._server receiveSpecLenBytes:expectDataLen];
            if (receiveData != nil)
            {
                [receiveData getBytes:&receiveOneByte length:1];
            }
            else
            {
                receiveOneByte = -1;
            }
            
            
            if (receiveOneByte == expectOneByte)
            {
                
                if (DEBUG_ON)
                {
                    NSLog(@"ESPTouchTask __listenAsyn() receive correct broadcast");
                }
                // change the socket's timeout
                NSTimeInterval consume = [[NSDate date] timeIntervalSince1970] - startTimestamp;
                int timeout = (int)([self._parameter getWaitUdpTotalMillisecond] - consume*1000);
                if (timeout < 0)
                {
                    if (DEBUG_ON)
                    {
                        NSLog(@"ESPTouchTask __listenAsyn() esptouch timeout");
                    }
                    break;
                }
                else
                {
                    if (DEBUG_ON)
                    {
                        NSLog(@"ESPTouchTask __listenAsyn() socketServer's new timeout is %d milliseconds",timeout);
                    }
                    [self._server setSocketTimeout:timeout];
                    if (DEBUG_ON)
                    {
                        NSLog(@"ESPTouchTask __listenAsyn() receive correct broadcast");
                    }
                    if (receiveData != nil)
                    {
                        NSString *bssid =
                        [ESP_ByteUtil parseBssid:(Byte *)[receiveData bytes]
                                          Offset:[self._parameter getEsptouchResultOneLen]
                                           Count:[self._parameter getEsptouchResultMacLen]];
                        NSData *inetAddrData =
                        [ESP_NetUtil parseInetAddrByData:receiveData
                                               andOffset:[self._parameter getEsptouchResultOneLen] + [self._parameter getEsptouchResultMacLen]
                                                andCount:[self._parameter getEsptouchResultIpLen]];
                        [self __putEsptouchResultIsSuc:YES AndBssid:bssid AndInetAddr:inetAddrData];
                    }
                }
            }
            else
            {
                if (DEBUG_ON)
                {
                    NSLog(@"ESPTouchTask __listenAsyn() receive rubbish message, just ignore");
                   
                }
            }
        }
        self._isSuc = [self._esptouchResultArray count] >= [self._parameter getExpectTaskResultCount];
        [self __interrupt];
        if (DEBUG_ON)
        {
            NSLog(@"ESPTouchTask __listenAsyn() finish");
        }
        [self endBackgroundTask];
    });
}

- (void) interrupt
{
    if (DEBUG_ON)
    {
        NSLog(@"ESPTouchTask interrupt()");
    }
    self.isCancelled = YES;
    [self __interrupt];
}

- (void) __interrupt
{
    self._isInterrupt = YES;
    [self._client interrupt];
    [self._server interrupt];
    // notify the ESPTouchTask to wake up from sleep mode
    [self __notify];
}

- (BOOL) __execute: (ESPTouchGenerator *)generator
{
    NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval currentTime = startTime;
    NSTimeInterval lastTime = currentTime - [self._parameter getTimeoutTotalCodeMillisecond];
    
    NSArray *gcBytes2 = [generator getGCBytes2];
    NSArray *dcBytes2 = [generator getDCBytes2];
    
//    NSError *error = nil;
//    if (![self.recvUdpSocket beginReceiving:&error])
//    {
//        [self.recvUdpSocket close];
//        // NSLog(@"Error starting server (recv): %@", error);
//    }
   NSData *ssidData = [self._apSsid dataUsingEncoding:NSUTF8StringEncoding];
//    
    NSData *dataToSend = [MCNUtilSmartConfigEncode buildConfigPacketWithSSID:ssidData key:self._apPwd IP:self.ip];
//    
//    
    int l = 0;
    int k = 1;
    int index = 0;
    
   while (!self._isInterrupt)
    {
//        if (currentTime - lastTime >= [self._parameter getTimeoutTotalCodeMillisecond]/1000.0)
//        {
//            if ([[NSDate date] timeIntervalSince1970] - startTime > [self._parameter getWaitUdpSendingMillisecond]/1000.0)
//            {
//                break;
//            }
//            if (DEBUG_ON)
//            {
//                NSLog(@"ESPTouchTask __execute() send gc code ");
//            }
//            // send guide code
//            while (!self._isInterrupt && [[NSDate date] timeIntervalSince1970] - currentTime < [self._parameter getTimeoutGuideCodeMillisecond]/1000.0)
//            {
//                [self._client sendDataWithBytesArray2:gcBytes2
//                                     ToTargetHostName:[self._parameter getTargetHostname]
//                                             WithPort:[self._parameter getTargetPort]
//                                          andInterval:[self._parameter getIntervalGuideCodeMillisecond]];
//               // NSLog(@"ESPTouchTask __execute() 2222 ");
//                // check whether the udp is send enough time
//                if ([[NSDate date] timeIntervalSince1970] - startTime > [self._parameter getWaitUdpSendingMillisecond]/1000.0)
//                {
//                    break;
//                }
//            }
//            //lastTime = currentTime;
//       
//            while (!self._isInterrupt && [[NSDate date] timeIntervalSince1970] - currentTime > [self._parameter getTimeoutGuideCodeMillisecond]/1000.0  && [[NSDate date] timeIntervalSince1970] - currentTime<6)
//                
//            
//        {
//            [self._client sendDataWithBytesArray2:dcBytes2
//                                           Offset:index
//                                            Count:ONE_DATA_LEN
//                                 ToTargetHostName:[self._parameter getTargetHostname]
//                                         WithPort:[self._parameter getTargetPort]
//                                      andInterval:[self._parameter getIntervalDataCodeMillisecond]];
//            index = (index + ONE_DATA_LEN) % [dcBytes2 count];
//           // NSLog(@"ESPTouchTask __execute() 4444 ");
//        
//        
//        // check whether the udp is send enough time
//        if ([[NSDate date] timeIntervalSince1970] - startTime > [self._parameter getWaitUdpSendingMillisecond]/1000.0)
//        {
//            break;
//        }
//    }
//      while (!self._isInterrupt && [[NSDate date] timeIntervalSince1970] - currentTime > 6 && [[NSDate date] timeIntervalSince1970] - currentTime <18) {
//        
//       // 新安县
//        
//        
//       
//        
//        Byte srcbs[1024] = {0};
//        [dataToSend getBytes:srcbs];
//        
//        k = 1;
//        
//        Byte *bDataToSend = (Byte *)[dataToSend bytes];
//        for (int i = 0; i < [dataToSend length]; i++)
//        {
//            l = (bDataToSend[i]+256)%256;
//            l = l==0 ? 129 : l;
//            l = k==1 ? (156 + l) : (156 - l);
//            k = 1 - k;
//            
//            Byte bs[l];
//            
//            NSData *srcbsData = [NSData dataWithBytes:srcbs length:1024];
//            [srcbsData getBytes:bs range:NSMakeRange(0, l)];
//            
//            for (int j = 0; j < 20; j++)
//            {
//                
//                NSData *send = [NSData dataWithBytes:bs length:l];
//                if ([[NSDate date] timeIntervalSince1970] - startTime > [self._parameter getWaitUdpSendingMillisecond]/1000.0)
//                {
//                    break;
//                }
//                //NSLog(@"发送udp数据 %ld",thetag);
//                [self.sendWifiUdpSocket sendData:send toHost:@"239.1.2.110" port:60001 withTimeout:0.2 tag:j];
//                
//                [NSThread sleepForTimeInterval:0.003];
//                
//            }
//            [NSThread sleepForTimeInterval:0.03];
//        }
        
        if (currentTime - lastTime >= [self._parameter getTimeoutTotalCodeMillisecond]/1000.0){
            if ([[NSDate date] timeIntervalSince1970] - startTime > [self._parameter getWaitUdpSendingMillisecond]/1000.0)
            {
                break;
            }
            
            if (DEBUG_ON)
            {
                NSLog(@"ESPTouchTask __execute() send gc code ");
            }
            
            // send guide code
            while (!self._isInterrupt && [[NSDate date] timeIntervalSince1970] - currentTime < [self._parameter getTimeoutGuideCodeMillisecond]/1000.0){
                [self._client sendDataWithBytesArray2:gcBytes2
                                     ToTargetHostName:[self._parameter getTargetHostname]
                                             WithPort:[self._parameter getTargetPort]
                                          andInterval:[self._parameter getIntervalGuideCodeMillisecond]];
                NSLog(@"ESPTouchTask __execute() 2222 ");
                // check whether the udp is send enough time
                if ([[NSDate date] timeIntervalSince1970] - startTime > [self._parameter getWaitUdpSendingMillisecond]/1000.0  || self.seedFlg)
                {
                    [self.sendWifiUdpSocket close];
                    break;
                }
            }
            lastTime = currentTime;
            continue;
        }else{
            while (!self._isInterrupt && [[NSDate date] timeIntervalSince1970] - currentTime > [self._parameter getTimeoutGuideCodeMillisecond]/1000.0  && [[NSDate date] timeIntervalSince1970] - currentTime<6){
                [self._client sendDataWithBytesArray2:dcBytes2
                                               Offset:index
                                                Count:ONE_DATA_LEN
                                     ToTargetHostName:[self._parameter getTargetHostname]
                                             WithPort:[self._parameter getTargetPort]
                                          andInterval:[self._parameter getIntervalDataCodeMillisecond]];
                index = (index + ONE_DATA_LEN) % [dcBytes2 count];
                NSLog(@"ESPTouchTask __execute() 4444 ");
                NSLog(@"%@",[NSThread currentThread]);
            }
        }
        
        NSThread *sendThread = [[NSThread alloc]initWithTarget:self selector:@selector(sendUdpDatagramToSocketWithWifiInfo) object:nil];
        [sendThread start];
        
        
        
        
        for (int i = 0; i < 3; i++) {
            Byte srcbs[1024] = {0};
            [dataToSend getBytes:srcbs];
            
            k = 1;
            
            Byte *bDataToSend = (Byte *)[dataToSend bytes];
            for (int i = 0; i < [dataToSend length]; i++)
            {
                l = (bDataToSend[i]+256)%256;
                l = l==0 ? 129 : l;
                l = k==1 ? (156 + l) : (156 - l);
                k = 1 - k;
                
                Byte bs[l];
                
                NSData *srcbsData = [NSData dataWithBytes:srcbs length:1024];
                [srcbsData getBytes:bs range:NSMakeRange(0, l)];
                
                for (int j = 0; j < 20; j++)
                {
                    
                    NSData *send = [NSData dataWithBytes:bs length:l];
                    if ([[NSDate date] timeIntervalSince1970] - startTime > [self._parameter getWaitUdpSendingMillisecond]/1000.0)
                    {
                        break;
                    }
                    // __weak ESPTouchTask *weakSelf = self;
                    
                    // [self.sendWifiUdpSocket sendData:send toHost:@"239.1.2.110" port:60001 withTimeout:0.2 tag:j];
                    
                    
                    [NSThread sleepForTimeInterval:0.003];
                    
                }
                [NSThread sleepForTimeInterval:0.03];
            }
        }
        
    
        lastTime = currentTime;
        currentTime = [[NSDate date] timeIntervalSince1970];
        if ([[NSDate date] timeIntervalSince1970] - startTime > [self._parameter getWaitUdpSendingMillisecond]/1000.0  || self.seedFlg)
        {
            [self.sendWifiUdpSocket close];
            break;
            
        }

   }
    
    return self._isSuc;
}

- (void) __checkTaskValid
{
    if (self._isExecutedAlready)
    {
        perror("ESPTouchTask __checkTaskValid() fail, the task could be executed only once");
    }
    // !!!NOTE: the esptouch task could be executed only once
    assert(!self._isExecutedAlready);
    self._isExecutedAlready = YES;
}

- (ESPTouchResult *) executeForResult
{
    return [[self executeForResults:1] objectAtIndex:0];
}

- (NSArray*) executeForResults:(int) expectTaskResultCount
{
    // set task result count
    if (expectTaskResultCount <= 0)
    {
        expectTaskResultCount = INT32_MAX;
    }
    [self._parameter setExpectTaskResultCount:expectTaskResultCount];
    
    [self __checkTaskValid];
    
    NSData *localInetAddrData = [ESP_NetUtil getLocalInetAddress];
    if (DEBUG_ON)
    {
        NSLog(@"ESPTouchTask executeForResult() localInetAddr: %@", [ESP_NetUtil descriptionInetAddrByData:localInetAddrData]);
    }
    // generator the esptouch byte[][] to be transformed, which will cost
    // some time(maybe a bit much)
    ESPTouchGenerator *generator = [[ESPTouchGenerator alloc]initWithSsid:self._apSsid andApBssid:self._apBssid andApPassword:self._apPwd andInetAddrData:localInetAddrData andIsSsidHidden:self._isSsidHidden];
    // listen the esptouch result asyn
  //  [self __listenAsyn:[self._parameter getEsptouchResultTotalLen]];
    BOOL isSuc = NO;
    for (int i = 0; i < [self._parameter getTotalRepeatTime]; i++)
    {
        isSuc = [self __execute:generator];
        if (isSuc)
        {
            return [self __getEsptouchResultList];
        }
    }
    
//    if (!self._isInterrupt)
//    {
//        [self __sleep: [self._parameter getWaitUdpReceivingMillisecond]];
//        [self __interrupt];
//    }
    
    return [self __getEsptouchResultList];
}

// sleep some milliseconds
- (BOOL) __sleep :(long) milliseconds
{
    if (DEBUG_ON)
    {
        NSLog(@"ESPTouchTask __sleep() start");
    }
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow: milliseconds/10000.0];
    [self._condition lock];
    BOOL signaled = NO;
    while (!self._isWakeUp && (signaled = [self._condition waitUntilDate:date]))
    {
    }
    [self._condition unlock];
    if (DEBUG_ON)
    {
        NSLog(@"ESPTouchTask __sleep() end, receive signal is %@", signaled ? @"YES" : @"NO");
    }
    return signaled;
}

// notify the sleep thread to wake up
- (void) __notify
{
    if (DEBUG_ON)
    {
        NSLog(@"ESPTouchTask __notify()");
    }
    [self._condition lock];
    self._isWakeUp = YES;
    [self._condition signal];
    [self._condition unlock];
}

- (void) setEsptouchDelegate: (NSObject<ESPTouchDelegate> *) esptouchDelegate
{
    self._esptouchDelegate = esptouchDelegate;
}


#pragma mark- UDP
////用于接收UDP数据报的Socket
//- (GCDAsyncUdpSocket *) recvUdpSocket
//{
//    NSLog(@"fafafafa");
//    
//    if(!_recvUdpSocket)
//    {
//        _recvUdpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
//        
//        NSError *error = nil;
//        
//        if (![_recvUdpSocket bindToPort:7788 error:&error])
//        {
//            
//            _recvUdpSocket = nil;
//        }
//    }
//    return _recvUdpSocket;
//}


//用于发送包含WIFI信息UDP数据报的Socket
- (GCDAsyncUdpSocket *) sendWifiUdpSocket
{
    
    // NSLog(@"一直发么");
    if(!_sendWifiUdpSocket)
    {
        _sendWifiUdpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        
        NSError *error = nil;
        
        if (![_sendWifiUdpSocket enableBroadcast:YES error:&error])
        {
            // NSLog(@"Error binding: %@", error);
            _sendWifiUdpSocket = nil;
        }
        if (![_sendWifiUdpSocket bindToPort:0 error:&error])
        {
            //  NSLog(@"Error binding: %@", error);
            _sendWifiUdpSocket = nil;
        }
    }
    return _sendWifiUdpSocket;
}

#pragma mark - 获取IP地址
- (NSString *) localWiFiIPAddress
{
    BOOL success;
    struct ifaddrs * addrs;
    const struct ifaddrs * cursor;
    
    success = getifaddrs(&addrs) == 0;
    if (success) {
        cursor = addrs;
        while (cursor != NULL) {
            // the second test keeps from picking up the loopback address
            if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0)
            {
                NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
                if ([name isEqualToString:@"en0"])  // Wi-Fi adapter
                    return [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return nil;
}
-(void)ZHUan
{
    NSArray *arr = [self.localWiFiIPAddress componentsSeparatedByString:@"."];
    
    NSString *hexS = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1X",[arr[0] intValue]]];
    NSString *hexS1 = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1X",[arr[1] intValue]]];
    NSString *hexS2 = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1X",[arr[2] intValue]]];
    NSString *hexS3 = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1X",[arr[3] intValue]]];
    
    if(hexS2.length< 2)
    {
        hexS2 = [NSString stringWithFormat:@"0%@",hexS2];
        
    }
    if(hexS3.length< 2)
    {
        hexS3 = [NSString stringWithFormat:@"0%@",hexS3];
        
    }
    
    self.ip = [NSString stringWithFormat:@"%@%@%@%@",hexS,hexS1,hexS2,hexS3];
    
    
}

-(void)sendUdpDatagramToSocketWithWifiInfo
{
    NSData *ssidData = [self._apSsid dataUsingEncoding:NSUTF8StringEncoding];
    //
    NSData *dataToSend = [MCNUtilSmartConfigEncode buildConfigPacketWithSSID:ssidData key:self._apPwd IP:self.ip];
    //
    //
    int l = 0;
    int k = 1;
    
    for (int i = 0; i < 3; i++) {
        Byte srcbs[1024] = {0};
        [dataToSend getBytes:srcbs];
        
        k = 1;
        
        Byte *bDataToSend = (Byte *)[dataToSend bytes];
        for (int i = 0; i < [dataToSend length]; i++)
        {
            l = (bDataToSend[i]+256)%256;
            l = l==0 ? 129 : l;
            l = k==1 ? (156 + l) : (156 - l);
            k = 1 - k;
            
            Byte bs[l];
            
            NSData *srcbsData = [NSData dataWithBytes:srcbs length:1024];
            [srcbsData getBytes:bs range:NSMakeRange(0, l)];
            
            for (int j = 0; j < 20; j++)
            {
                
                NSData *send = [NSData dataWithBytes:bs length:l];
                
                //NSLog(@"发送udp数据 %ld",thetag);
                
                [self.sendWifiUdpSocket sendData:send toHost:@"239.1.2.110" port:60001 withTimeout:0.2 tag:j];
                NSLog(@"ffffffff");
                if(self.seedFlg)
                {
                    [self.sendWifiUdpSocket close];
                    
                    break;
                }
                
                [NSThread sleepForTimeInterval:0.003];
                
            }
            [NSThread sleepForTimeInterval:0.03];
        }
    }
    
    [[NSThread currentThread] cancel];
    
    
    
}




-(void)sendflgs
{
    self.seedFlg = true;
 
}


@end
