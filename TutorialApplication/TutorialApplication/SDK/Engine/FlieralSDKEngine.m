//
//  FlieralSDKEngine.m
//  TutorialApplication
//
//  Created by Alireza Arabi on 9/17/16.
//  Copyright © 2016 Flieral Inc. All rights reserved.
//

#import "FlieralSDKEngine.h"

#define PLACEMENTHASHIDKEY		@"FlieralPlacementHashIDKey"
#define PLACEMENTPRIORTYKEY		@"FlieralPlacementPriorityKey"
#define PLACEMENTCACHEDKEY		@"FlieralPlacementCachedContentKey"
#define PUBLISHERHASHIDKEY		@"FlieralPublisherHashIDKey"

@interface FlieralSDKEngine ()

@property (nonatomic, strong) NSMutableArray *placementHashIdArray;

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
	});
	
	return sharedService;
}

#pragma mark - Authentication

- (void)Authenticate:(nonnull NSString *)publisherHashID
{
	NSDictionary *dict = [NSDictionary dictionary];
	[dict setValue:publisherHashID forKey:PUBLISHERHASHIDKEY];
}

#pragma mark - Add Placement

- (void)AddPlacement:(nonnull NSString *)placementHashID
{
	NSDictionary *dict = [NSDictionary dictionary];
	[dict setValue:placementHashID forKey:PLACEMENTHASHIDKEY];
	[dict setValue:[NSString stringWithFormat:@"%li", (long)LowPriority] forKey:PLACEMENTPRIORTYKEY];
	[dict setValue:[NSString stringWithFormat:@"%li", (long)LowNumber] forKey:PLACEMENTCACHEDKEY];
	
	[_placementHashIdArray addObject:dict];
}

- (void)AddPlacement:(nonnull NSString *)placementHashID Priority:(Priority)priority
{
	NSDictionary *dict = [NSDictionary dictionary];
	[dict setValue:placementHashID forKey:PLACEMENTHASHIDKEY];
	[dict setValue:[NSString stringWithFormat:@"%li", (long)priority] forKey:PLACEMENTPRIORTYKEY];
	[dict setValue:[NSString stringWithFormat:@"%li", (long)LowNumber] forKey:PLACEMENTCACHEDKEY];
	
	[_placementHashIdArray addObject:dict];
}

- (void)AddPlacement:(nonnull NSString *)placementHashID CachedContentNumber:(CachedContentNumber)cachedContentNumber
{
	NSDictionary *dict = [NSDictionary dictionary];
	[dict setValue:placementHashID forKey:PLACEMENTHASHIDKEY];
	[dict setValue:[NSString stringWithFormat:@"%li", (long)LowPriority] forKey:PLACEMENTPRIORTYKEY];
	[dict setValue:[NSString stringWithFormat:@"%li", (long)cachedContentNumber] forKey:PLACEMENTCACHEDKEY];
	
	[_placementHashIdArray addObject:dict];
}

#pragma mark - Start Flieral Engine

- (void)StartEingine
{
	
}

#pragma mark - Placement Manager

- (nullable FlieralPlacementManager *)GetPlacementAtIndex:(NSInteger)index
{
	if (index < 0 || index >= _placementHashIdArray.count)
		return NULL;
	return [_placementHashIdArray objectAtIndex:index];
}

- (NSDictionary *)RetrivePlacementInformation
{
	NSDictionary *dict = [NSDictionary dictionary];
	return dict;
}

#pragma mark - Offline Setting

- (NSDictionary *)RetriveOfflineInformation
{
	NSDictionary *dict = [NSDictionary dictionary];
	return dict;
}

@end
