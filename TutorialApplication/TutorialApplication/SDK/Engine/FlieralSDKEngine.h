//
//  FlieralSDKEngine.h
//  TutorialApplication
//
//  Created by Alireza Arabi on 9/17/16.
//  Copyright © 2016 Flieral Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FlieralPlacementManager;

@interface FlieralSDKEngine : NSObject

+ (nullable FlieralSDKEngine *)SDKEngine:(nullable NSDictionary *)setting;

- (void)Authenticate:(nonnull NSString *)publisherHashID ApplicationHashID:(nonnull NSString *)applicationHashID;

- (void)AddPlacement:(nonnull NSString *)placementHashID;

- (void)StartEngine;

- (BOOL)LogEnable;

- (nullable FlieralPlacementManager *)GetPlacementWithHashID:(nonnull NSString *)placementHashID;

@end
