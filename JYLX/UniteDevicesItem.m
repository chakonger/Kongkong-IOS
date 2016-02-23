//
//  UniteDevicesItem.m
//  Control
//
//  Created by ToTank on 15/12/10.
//  Copyright © 2015年 lvjianxiong. All rights reserved.
//

#import "UniteDevicesItem.h"
#import "AppDelegate.h"


@implementation UniteDevicesItem

@dynamic infraTypeID;
@dynamic lastInst;
@dynamic devType;
@dynamic devID;
@dynamic devTypeID;
@dynamic panelType;
@dynamic infraName;
@dynamic bigType;
@dynamic subWeight;
@dynamic logoSet;


@end

@implementation UniteDevicesItemVO


@synthesize infraTypeID;
@synthesize lastInst;
@synthesize devType;
@synthesize devID;
@synthesize devTypeID;
@synthesize panelType;
@synthesize infraName;
@synthesize bigType;
@synthesize subWeight;
@synthesize logoSet;

@end

@implementation UniteDevicesItemDB


-(void)initManagedObjectContext
{
    while(TRUE){
        //////////////////////////////////////////////////////////////////////////////////////
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"JYLX" withExtension:@"momd"];
        NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        if(managedObjectModel ==Nil){
            sleep(1);continue;
        }
        
        AppDelegate *appdelegate = ((AppDelegate *)[UIApplication sharedApplication].delegate);
        
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
        
        self.managedObjectContext = [[NSManagedObjectContext alloc]init];
        [self.managedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];
        
        if (self.managedObjectContext != nil) {
            return ;
        }
        sleep(1);
    }
    
    
    
}


-(void)setMsgAction:(UniteDevicesItemVO *)vo
{
    NSError *error;
    
    UniteDevicesItem *UniteDevicesItem = [NSEntityDescription insertNewObjectForEntityForName:@"UniteDevicesItem" inManagedObjectContext:self.managedObjectContext];
    
    UniteDevicesItem.infraTypeID = vo.infraTypeID;
    UniteDevicesItem.lastInst = vo.lastInst;
    UniteDevicesItem.devType = vo.devType;
    UniteDevicesItem.devID = vo.devID;
    UniteDevicesItem.devTypeID = vo.devTypeID;
    UniteDevicesItem.panelType = vo.panelType;
    UniteDevicesItem.infraName = vo.infraName;
    UniteDevicesItem.bigType = vo.bigType;
    UniteDevicesItem.subWeight = vo.subWeight;
    UniteDevicesItem.logoSet = vo.logoSet;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error: %@", [error localizedDescription]);
        return;
    }
}

- (void)saveUniteDeviceAction:(NSArray *)deviceArray
{

    NSError *error;
    for (UniteDevicesItemVO *vo in deviceArray) {
        UniteDevicesItem *UniteDevicesItem = [NSEntityDescription insertNewObjectForEntityForName:@"UniteDevicesItem" inManagedObjectContext:self.managedObjectContext];
        UniteDevicesItem.devID = vo.devID;
        UniteDevicesItem.subWeight = vo.subWeight;
        UniteDevicesItem.logoSet = vo.logoSet;
        UniteDevicesItem.devType = [[NSNull null] isEqual:vo.devType]?@"":vo.devType;
        UniteDevicesItem.lastInst = vo.lastInst;
        UniteDevicesItem.bigType = [[NSNull null] isEqual:vo.bigType]?@"":vo.bigType;
        UniteDevicesItem.panelType = vo.panelType;
        UniteDevicesItem.infraName = vo.infraName;
        UniteDevicesItem.infraTypeID = vo.infraTypeID;
        
        UniteDevicesItem.devTypeID = vo.devTypeID;
    
    if (![self.managedObjectContext save:&error]) {
        //  NSLog(@"Error: %@", [error localizedDescription]);
        return;
    }

}




}


- (NSMutableArray *)getAllMsgAction:(NSString *)devID
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entiry = [NSEntityDescription entityForName:@"UniteDevicesItem" inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@" devID =%@ ",devID];
    
    [fetchRequest setPredicate:predicate];
    
    [fetchRequest setEntity:entiry];
    NSError *error;
    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:0];
    NSArray *msgArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (UniteDevicesItem *item in msgArray) {
        UniteDevicesItemVO *deviceItem = [[UniteDevicesItemVO alloc] init];
        deviceItem.devType = item.devType;
        deviceItem.infraTypeID = item.infraTypeID;
        deviceItem.lastInst = item.lastInst;
        deviceItem.devID = item.devID;
        deviceItem.panelType = item.panelType;
        deviceItem.bigType = item.bigType;
        deviceItem.subWeight = item.subWeight;
        deviceItem.devTypeID = item.devTypeID;
        deviceItem.infraName = item.infraName;
        deviceItem.logoSet = item.logoSet;
        [resultArray addObject:deviceItem];
    }
    return resultArray;


}


- (NSMutableArray *)getMsgAction:(NSString *)devID With:(NSString *)infraTypeID
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entiry = [NSEntityDescription entityForName:@"UniteDevicesItem" inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@" devID =%@ and infraTypeID =  %@",devID,infraTypeID];
    
    [fetchRequest setPredicate:predicate];
    
    [fetchRequest setEntity:entiry];
    NSError *error;
    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:0];
    NSArray *msgArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (UniteDevicesItem *item in msgArray) {
        UniteDevicesItemVO *deviceItem = [[UniteDevicesItemVO alloc] init];
        deviceItem.devType = item.devType;
        deviceItem.infraTypeID = item.infraTypeID;
        deviceItem.lastInst = item.lastInst;
        deviceItem.devID = item.devID;
        deviceItem.panelType = item.panelType;
        deviceItem.bigType = item.bigType;
        deviceItem.subWeight = item.subWeight;
        deviceItem.devTypeID = item.devTypeID;
        deviceItem.infraName = item.infraName;
        deviceItem.logoSet = item.logoSet;
        [resultArray addObject:deviceItem];
    }
    return resultArray;
    
    
}

-(NSString *)getMseAction:(NSString *)devID With:(NSString *)devTypeID
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entiry = [NSEntityDescription entityForName:@"UniteDevicesItem" inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@" devID =%@ and devTypeID =  %@",devID,devTypeID];
    
    [fetchRequest setPredicate:predicate];
    
    [fetchRequest setEntity:entiry];
    NSError *error;
    NSString *resultlog = @"";
    NSArray *msgArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (UniteDevicesItem *item in msgArray) {
        UniteDevicesItemVO *deviceItem = [[UniteDevicesItemVO alloc] init];
        deviceItem.devType = item.devType;
        deviceItem.infraTypeID = item.infraTypeID;
        deviceItem.lastInst = item.lastInst;
        deviceItem.devID = item.devID;
        deviceItem.panelType = item.panelType;
        deviceItem.bigType = item.bigType;
        deviceItem.subWeight = item.subWeight;
        deviceItem.devTypeID = item.devTypeID;
        deviceItem.infraName = item.infraName;
        deviceItem.logoSet = item.logoSet;
        
        resultlog = deviceItem.logoSet;
    }
    return resultlog;
}


- (void)removeAllUniteDeviceAction:(NSString *)devID{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UniteDevicesItem" inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@" devID =%@",devID];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjectsArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (UniteDevicesItem *deviceItem in fetchedObjectsArray) {
        [self.managedObjectContext deleteObject:deviceItem];
    }
    if (![self.managedObjectContext save:&error])
        NSLog(@"Error: %@", [error localizedDescription]);
}

- (void)updateDeviceAction:(UniteDevicesItemVO *)vo{
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"UniteDevicesItem" inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@" devID = %@ and infraName = %@  ",vo.devID,vo.infraName];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    
    NSError * requestError = nil;
    NSArray * deviceArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&requestError];
    
    if ([deviceArray count] > 0) {
        UniteDevicesItem * deviceItem = [deviceArray lastObject];
        // 更新数据
        deviceItem.lastInst = vo.lastInst;
       
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
- (void)removeAllUniteDeviceAction{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UniteDevicesItem" inManagedObjectContext:self.managedObjectContext];
   
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjectsArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (UniteDevicesItem *deviceItem in fetchedObjectsArray) {
        [self.managedObjectContext deleteObject:deviceItem];
    }
    if (![self.managedObjectContext save:&error])
        NSLog(@"Error: %@", [error localizedDescription]);
}

- (void)removeOneUniteDeviceAction:(NSString *)devID With:(NSString *)infraTypeID
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UniteDevicesItem" inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@" devID =%@ and infraTypeID =  %@",devID,infraTypeID];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjectsArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (UniteDevicesItem *deviceItem in fetchedObjectsArray) {
        [self.managedObjectContext deleteObject:deviceItem];
    }
    if (![self.managedObjectContext save:&error])
        NSLog(@"Error: %@", [error localizedDescription]);




}

@end


