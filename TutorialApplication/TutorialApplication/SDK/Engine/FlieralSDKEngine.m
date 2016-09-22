//
//  FlieralSDKEngine.m
//  TutorialApplication
//
//  Created by Alireza Arabi on 9/17/16.
//  Copyright © 2016 Flieral Inc. All rights reserved.
//

#import "FlieralSDKEngine.h"
#import "FlieralPlacementManager.h"
#import "APIManager.h"
#import "MonitorManager.h"

#define PLACEMENTHASHIDKEY		@"FlieralPlacementHashIDKey"
#define PLACEMENTPRIORTYKEY		@"FlieralPlacementPriorityKey"
#define PLACEMENTCACHEDKEY		@"FlieralPlacementCachedContentKey"
#define PUBLISHERHASHIDKEY		@"FlieralPublisherHashIDKey"

#define STORAGEAUTHENTICATIONKEY	@"FlieralStoragePublisherHashIDKey"
#define STORAGEOFFLINEMODEKEY		@"FlieralSTORAGEOfflineModeKey"
#define STORAGEONLINEMODEKEY		@"FlieralSTORAGEOnlineModeKey"
#define STORAGEMONITORINGKEY		@"FlieralSTORAGEMonitoringKey"

#define JSONAUTHENTICATIONKEY		@"Authentication"
#define JSONOFFLINEMODEKEY			@"OfflineMode"
#define JSONONLINEMODEKEY			@"OnlineMode"
#define JSONMONITORINGKEY			@"Monitoring"

@interface FlieralSDKEngine () <MonitorManagerDelegate>

@property (nonatomic, strong) NSMutableArray *placementHashIdArray;
@property (nonatomic, strong) NSMutableArray *placementManagerArray;
@property (nonatomic, strong) MonitorManager *monitor;

@property (nonatomic) BOOL readyForStart;
@property (nonatomic) BOOL readyForUse;

@end

@implementation FlieralSDKEngine

#pragma mark - Shared Instance Singelton

+ (nullable FlieralSDKEngine *)SDKEngine:(nullable NSDictionary *)setting
{
	static FlieralSDKEngine* sharedService = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		sharedService = [self new];
		
		sharedService.placementHashIdArray = [NSMutableArray array];
		sharedService.placementManagerArray = [NSMutableArray array];
		sharedService.readyForUse = false;
		sharedService.readyForStart = false;
		
		sharedService.monitor = [[MonitorManager alloc] init];
		[sharedService.monitor startPinging];
	});
	
	return sharedService;
}

#pragma mark - Authentication

- (void)Authenticate:(nonnull NSString *)publisherHashID
{
	NSDictionary *dict = [NSDictionary dictionary];
	[dict setValue:publisherHashID forKey:PUBLISHERHASHIDKEY];
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	[ud setObject:dict forKey:STORAGEAUTHENTICATIONKEY];
	[ud synchronize];
}

- (NSDictionary *)GetAuthenticationCredential
{
	NSDictionary *dict = [NSDictionary dictionary];
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	dict = [ud objectForKey:STORAGEAUTHENTICATIONKEY];
	return dict;
}

#pragma mark - Add Placement

- (void)AddPlacement:(nonnull NSString *)placementHashID
{
	NSDictionary *dict = [NSDictionary dictionary];
	[dict setValue:placementHashID forKey:PLACEMENTHASHIDKEY];
	[dict setValue:[NSString stringWithFormat:@"%li", (long)LowPriority] forKey:PLACEMENTPRIORTYKEY];
	[dict setValue:[NSString stringWithFormat:@"%li", (long)LowNumber] forKey:PLACEMENTCACHEDKEY];
	
	[_placementHashIdArray addObject:dict];
	
	FlieralPlacementManager *placementManager = [[FlieralPlacementManager alloc] initWithHashID:placementHashID];
	[_placementManagerArray addObject:placementManager];
}

- (void)AddPlacement:(nonnull NSString *)placementHashID Priority:(Priority)priority
{
	NSDictionary *dict = [NSDictionary dictionary];
	[dict setValue:placementHashID forKey:PLACEMENTHASHIDKEY];
	[dict setValue:[NSString stringWithFormat:@"%li", (long)priority] forKey:PLACEMENTPRIORTYKEY];
	[dict setValue:[NSString stringWithFormat:@"%li", (long)LowNumber] forKey:PLACEMENTCACHEDKEY];
	
	[_placementHashIdArray addObject:dict];
	
	FlieralPlacementManager *placementManager = [[FlieralPlacementManager alloc] initWithHashID:placementHashID];
	[_placementManagerArray addObject:placementManager];
}

- (void)AddPlacement:(nonnull NSString *)placementHashID CachedContentNumber:(CachedContentNumber)cachedContentNumber
{
	NSDictionary *dict = [NSDictionary dictionary];
	[dict setValue:placementHashID forKey:PLACEMENTHASHIDKEY];
	[dict setValue:[NSString stringWithFormat:@"%li", (long)LowPriority] forKey:PLACEMENTPRIORTYKEY];
	[dict setValue:[NSString stringWithFormat:@"%li", (long)cachedContentNumber] forKey:PLACEMENTCACHEDKEY];
	
	[_placementHashIdArray addObject:dict];
	
	FlieralPlacementManager *placementManager = [[FlieralPlacementManager alloc] initWithHashID:placementHashID];
	[_placementManagerArray addObject:placementManager];
}

#pragma mark - Start Flieral Engine

- (void)StartEngine
{
	if (_readyForStart)
	{
		NSDictionary *jsonObject = [NSDictionary dictionary];
		
		NSDictionary *authRequestContent = [self GetAuthenticationCredential];
		if (![authRequestContent isEqual:NULL])
			[jsonObject setValue:authRequestContent forKey:JSONAUTHENTICATIONKEY];
		
		NSDictionary *firstRequestContent = [self RetriveOfflineInformation];
		if (![firstRequestContent isEqual:NULL])
			[jsonObject setValue:firstRequestContent forKey:JSONOFFLINEMODEKEY];
		
		NSDictionary *secondRequestContent = [self RetriveOnlineInformation];
		if (![secondRequestContent isEqual:NULL])
			[jsonObject setValue:secondRequestContent forKey:JSONONLINEMODEKEY];
		
		NSDictionary *thirdRequestContent = [self RetriveMonitoringInformation];
		if (![thirdRequestContent isEqual:NULL])
			[jsonObject setValue:thirdRequestContent forKey:JSONMONITORINGKEY];
		
		[APIManager sendInformationToBackend:jsonObject SuccessBlock:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
			
			NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
			if (httpResponse.statusCode == 200)
			{
				for (FlieralPlacementManager *plManager in _placementManagerArray) {
					
				}
				_readyForUse = true;
			}
			
		} failedBlock:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
			
			_readyForUse = false;
		}];
	}
}

#pragma mark - Placement Manager

- (nullable FlieralPlacementManager *)GetPlacementWithHashID:(nonnull NSString *)placementHashID;
{
	if (_readyForUse)
	{
		int index = 0;
		for (NSDictionary *dict in _placementHashIdArray) {
			if ([[dict valueForKey:PLACEMENTHASHIDKEY] isEqualToString:placementHashID])
				[_placementManagerArray objectAtIndex:index];
			index ++;
		}
	}
	return nil;
}

#pragma mark - Online Setting

- (NSDictionary *)RetriveOnlineInformation
{
	NSDictionary *dict = [NSDictionary dictionary];
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	dict = [ud objectForKey:STORAGEONLINEMODEKEY];
	return dict;
}

#pragma mark - Offline Setting

- (NSDictionary *)RetriveOfflineInformation
{
	NSDictionary *dict = [NSDictionary dictionary];
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	dict = [ud objectForKey:STORAGEOFFLINEMODEKEY];
	return dict;
}

#pragma mark - Monitoring Setting

- (NSDictionary *)RetriveMonitoringInformation
{
	NSDictionary *dict = [NSDictionary dictionary];
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	dict = [ud objectForKey:STORAGEMONITORINGKEY];
	return dict;
}

#pragma mark - Monitoring Delegate

- (void)monitoringCompleteObject:(nonnull NSDictionary *)monitor
{
	_readyForStart = true;
	[self StartEngine];
}

@end
