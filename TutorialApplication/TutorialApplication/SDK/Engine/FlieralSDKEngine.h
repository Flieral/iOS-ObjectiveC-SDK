//
//  FlieralSDKEngine.h
//  TutorialApplication
//
//  Created by Alireza Arabi on 9/17/16.
//  Copyright © 2016 Flieral Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlieralPlacementManager.h"

typedef NS_ENUM(NSInteger, Priority)
{
	LowPriority = 1,
	HighPriority = 2
	
} priorityState;

typedef NS_ENUM(NSInteger, CachedContentNumber)
{
	LowNumber = 1,
	MidleNumber = 2,
	HighNumber = 3
	
} cachedContentNumberState;

@interface FlieralSDKEngine : NSObject

+ (nullable FlieralSDKEngine *)SDKEngine:(nullable NSDictionary *)setting;

- (void)Authenticate:(nonnull NSString *)publisherHashID;

- (void)AddPlacement:(nonnull NSString *)placementHashID;
- (void)AddPlacement:(nonnull NSString *)placementHashID Priority:(Priority)priority;
- (void)AddPlacement:(nonnull NSString *)placementHashID CachedContentNumber:(CachedContentNumber)cachedContentNumber;

- (void)StartEingine;

- (nullable FlieralPlacementManager *)GetPlacementAtIndex:(NSInteger)index;

@end
