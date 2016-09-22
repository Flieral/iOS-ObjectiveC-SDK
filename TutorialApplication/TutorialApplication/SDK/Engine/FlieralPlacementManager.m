//
//  FlieralPlacementManager.m
//  TutorialApplication
//
//  Created by Alireza Arabi on 9/17/16.
//  Copyright © 2016 Flieral Inc. All rights reserved.
//

#import "FlieralPlacementManager.h"
#import "PlacementController.h"
#import "Reachability.h"

@interface FlieralPlacementManager ()
{
	Reachability *internetReachabilityChecker;
}

@property (nonatomic, strong) PlacementController  * _Nonnull placementController;

@end

@implementation FlieralPlacementManager

- (nullable id)initWithHashID:(nullable NSString *)hashID
{
	self = [super init];
	if (self)
	{
		internetReachabilityChecker = [Reachability reachabilityForInternetConnection];
		_placementController = [[PlacementController alloc] initWithHashID:hashID];
	}
	return self;
}

#pragma mark - Default Setting

- (void)SetDefaultPosition:(CGPoint)point
{
	[_placementController setDefaultPosition:point];
}

- (void)SetParentView:(nonnull UIView *)parentView
{
	[_placementController setParentView:parentView];
}

#pragma mark - Block Event Action Listener

- (void)SetPreLoadBlock:(nullable void (^)(NSDictionary * _Nonnull details)) preLoadBlock
{
	[_placementController setPreLoadBlock:preLoadBlock];
}

- (void)SetDidLoadBlock:(nullable void (^)(NSDictionary * _Nonnull details)) didLoadBlock
{
	[_placementController setDidLoadBlock:didLoadBlock];
}

- (void)SetFailedLoadBlock:(nullable void (^)(NSDictionary * _Nonnull details)) failedLoadBlock
{
	[_placementController setFailedLoadBlock:failedLoadBlock];
}

- (void)SetWillAppearBlock:(nullable void (^)(NSDictionary * _Nonnull details)) willAppearBlock
{
	[_placementController setWillAppearBlock:willAppearBlock];
}

- (void)SetDidAppearBlock:(nullable void (^)(NSDictionary * _Nonnull details)) didAppearBlock
{
	[_placementController setDidAppearBlock:didAppearBlock];
}

- (void)SetWillDisappearBlock:(nullable void (^)(NSDictionary * _Nonnull details)) willDisappearBlock
{
	[_placementController setWillDisappearBlock:willDisappearBlock];
}

- (void)SetDidDisappearBlock:(nullable void (^)(NSDictionary * _Nonnull details)) didDisappearBlock
{
	[_placementController SetDidDisappearBlock:didDisappearBlock];
}

#pragma mark - Main Actions

- (void)Hide
{
	if (![_placementController getParentView])
		return;
	
	[_placementController hideContent];
}

- (void)Show
{
	if (![_placementController getParentView])
		return;

	if ([internetReachabilityChecker isReachable])
		[_placementController showOnlineContent];
	else
		[_placementController showOfflineContent];
}

@end
