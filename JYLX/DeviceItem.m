//
//  DeviceItem.m
//  Control
//
//  Created by kucababy on 15/2/28.
//  Copyright (c) 2015年 lvjianxiong. All rights reserved.
//

#import "DeviceItem.h"
#import "AppDelegate.h"

@implementation DeviceItem

@dynamic deviceName;
@dynamic devType;
@dynamic devStatus;
@dynamic lastInst;
@dynamic devID;
@dynamic bigType;
@dynamic brand;
@dynamic infraName;
@dynamic serialNumber;
@dynamic modelName;
@dynamic buyTime;
@dynamic infraTypeID;
@dynamic devTypeID;

@end


@implementation DeviceItemVO

@synthesize deviceName;
@synthesize devType;
@synthesize devStatus;
@synthesize lastInst;
@synthesize devID;
@synthesize bigType;
@synthesize brand;
@synthesize infraName;
@synthesize infraTypeID;
@synthesize serialNumber;
@synthesize modelName;
@synthesize buyTime;
@synthesize devTypeID;

@end

@implementation DeviceItemDB

- (void )initManagedObjectContext
{
    while(TRUE){
        //////////////////////////////////////////////////////////////////////////////////////
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"JYLX" withExtension:@"momd"];
        NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        if(managedObjectModel ==Nil){
            sleep(1);continue;
        }
        AppDelegate *appdelegate =  (AppDelegate *)[UIApplication sharedApplication].delegate;
        NSURL *storeURL = [[appdelegate applicationDocumentsDirectory] URLByAppendingPathComponent:@"JYLX.sqlite"];
        
        NSError *error = nil;
        NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
        if(persistentStoreCoordinator == Nil){
            sleep(1);continue;
        }
        
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
        
        if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
         //   NSLog(@"NewsItemDB initManageObjectContext error=%@",error);
            sleep(1);continue;
        }
        ////////////////////////////////////////////////////////////////////////////////////////
        
        self.managedObjectContext = [[NSManagedObjectContext alloc] init];
        [self.managedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];
        
        if (self.managedObjectContext != nil) {
            return ;
        }
        sleep(1);
    }
}

- (void)saveDeviceAction:(NSArray *)deviceArray{
    NSError *error;
    for (DeviceItemVO *vo in deviceArray) {
        DeviceItem *deviceItem = [NSEntityDescription insertNewObjectForEntityForName:@"DeviceItem" inManagedObjectContext:self.managedObjectContext];
        deviceItem.devID = vo.devID;
        deviceItem.deviceName = vo.deviceName;
        deviceItem.devStatus = vo.devStatus;
        deviceItem.devType = [[NSNull null] isEqual:vo.devType]?@"":vo.devType;
        deviceItem.lastInst = vo.lastInst;
        deviceItem.bigType = [[NSNull null] isEqual:vo.bigType]?@"":vo.bigType;
        deviceItem.brand = vo.brand;
        deviceItem.infraName = vo.infraName;
        deviceItem.buyTime = vo.buyTime;
        deviceItem.devTypeID = vo.devTypeID;
        deviceItem.infraTypeID = vo.infraTypeID;
        deviceItem.serialNumber = vo.serialNumber;
        deviceItem.modelName = vo.modelName;
        deviceItem.token = vo.token;
        deviceItem.seed = vo.seed;
    }
    if (![self.managedObjectContext save:&error]) {
      //  NSLog(@"Error: %@", [error localizedDescription]);
        return;
    }
}

- (NSMutableArray *)getAllDeviceAction{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entiry = [NSEntityDescription entityForName:@"DeviceItem" inManagedObjectContext:self.managedObjectContext];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"devID" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    [fetchRequest setEntity:entiry];
    NSError *error;
    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:0];
    NSArray *msgArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (DeviceItem *item in msgArray) {
        DeviceItemVO *deviceItem = [[DeviceItemVO alloc] init];
        deviceItem.devType = item.devType;
        deviceItem.devStatus = item.devStatus;
        deviceItem.deviceName = item.deviceName;
        deviceItem.devID = item.devID;
        deviceItem.lastInst = item.lastInst;
        deviceItem.bigType = item.bigType;
        deviceItem.brand = item.brand;
        deviceItem.infraTypeID = item.infraTypeID;
        deviceItem.infraName = item.infraName;
        deviceItem.serialNumber = item.serialNumber;
        deviceItem.modelName = item.modelName;
        deviceItem.buyTime = item.buyTime;
        deviceItem.devTypeID = item.devTypeID;
        deviceItem.seed = item.seed;
        deviceItem.token = item.token;
        [resultArray addObject:deviceItem];
    }
    return resultArray;
}

- (DeviceItemVO *)getDeviceAction:(NSString *)devID{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entiry = [NSEntityDescription entityForName:@"DeviceItem" inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@" devID =%@ ",devID];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entiry];
    NSError *error;
    NSArray *msgArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    DeviceItemVO *deviceItem = nil;
    if ([msgArray count]>0) {
        DeviceItem *item = [msgArray objectAtIndex:0];
        deviceItem = [[DeviceItemVO alloc] init];
        deviceItem.devType = item.devType;
        deviceItem.devStatus = item.devStatus;
        deviceItem.deviceName = item.deviceName;
        deviceItem.devID = item.devID;
        deviceItem.infraTypeID = item.infraTypeID;
        deviceItem.lastInst = item.lastInst;
        deviceItem.bigType = item.bigType;
        deviceItem.brand = item.brand;
        deviceItem.infraName = item.infraName;
        deviceItem.serialNumber = item.serialNumber;
        deviceItem.modelName = item.modelName;
        deviceItem.buyTime = item.buyTime;
        deviceItem.devTypeID = item.devTypeID;
        deviceItem.token = item.token;
        deviceItem.seed = item.seed;
    }
    return deviceItem;
}

- (void)removeAllDeviceAction{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DeviceItem" inManagedObjectContext:self.managedObjectContext];

    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjectsArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (DeviceItem *deviceItem in fetchedObjectsArray) {
        [self.managedObjectContext deleteObject:deviceItem];
    }
    if (![self.managedObjectContext save:&error])
        NSLog(@"Error: %@", [error localizedDescription]);
}

- (void)removeDeviceByAction:(NSString *)devID{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DeviceItem" inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@" devID = %@ ",devID];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjectsArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (DeviceItem *deviceItem in fetchedObjectsArray) {
        [self.managedObjectContext deleteObject:deviceItem];
    }
    if (![self.managedObjectContext save:&error])
        NSLog(@"Error: %@", [error localizedDescription]);
}

- (void)updateDeviceAction:(DeviceItemVO *)vo{
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"DeviceItem" inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@" devID = %@  ",vo.devID];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    
    NSError * requestError = nil;
    NSArray * deviceArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&requestError];
    
    if ([deviceArray count] > 0) {
        DeviceItem * deviceItem = [deviceArray lastObject];
        // 更新数据
        deviceItem.devType = vo.devType;
        deviceItem.deviceName = vo.deviceName;
        deviceItem.devStatus = vo.devStatus;
        deviceItem.bigType = vo.bigType;
        deviceItem.brand = vo.brand;
        deviceItem.infraName = vo.infraName;
        deviceItem.serialNumber = vo.serialNumber;
        deviceItem.modelName = vo.modelName;
        deviceItem.buyTime = vo.buyTime;
        deviceItem.infraTypeID = vo.infraTypeID;
        deviceItem.devTypeID = vo.devTypeID;
        deviceItem.seed = vo.seed;
        deviceItem.token = vo.seed;
        NSError * savingError = nil;
        if ([self.managedObjectContext save:&savingError]) {
          //  NSLog(@"successfully saved the context");
        }else {
           // NSLog(@"failed to save the context error = %@", savingError);
        }
    }else {
       // NSLog(@"could not find any person entity in the context");
    }
}
@end

