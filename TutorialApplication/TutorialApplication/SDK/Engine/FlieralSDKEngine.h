//
//  FlieralSDKEngine.h
//  TutorialApplication
//
//  Created by Alireza Arabi on 9/17/16.
//  Copyright © 2016 Flieral Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, VerboseType)
{
    None    = 0,
    _V      = 1,
    _VV     = 2,
    _VVV    = 3
    
} verboseType;

@class FlieralPlacementManager;

@interface FlieralSDKEngine : NSObject

+ (nullable FlieralSDKEngine *)SDKEngine:(nullable NSDictionary *)setting;

- (void)Authenticate:(nonnull NSString *)publisherHashID ApplicationHashID:(nonnull NSString *)applicationHashID;

- (void)AddPlacement:(nonnull NSString *)placementHashID;

- (void)StartEngine;

- (BOOL)LogEnable;

- (VerboseType)VerboseLevel;

- (nullable FlieralPlacementManager *)GetPlacementWithHashID:(nonnull NSString *)placementHashID;

- (void)SendContentRequest:(nullable NSArray *)placementsArray AfterSeconds:(int)time;

@end
