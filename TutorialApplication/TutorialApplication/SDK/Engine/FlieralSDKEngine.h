//
//  FlieralSDKEngine.h
//  TutorialApplication
//
//  Created by Alireza Arabi on 9/17/16.
//  Copyright © 2016 Flieral Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlieralPlacementManager.h"

typedef NS_ENUM(NSInteger, VerboseType)
{
    None    = 0,
    _V      = 1,
    _VV     = 2,
    _VVV    = 3
    
} verboseType;

@interface FlieralSDKEngine : NSObject

+ (nullable FlieralSDKEngine *)SDKEngine;

- (void)AddSetting:(nullable NSMutableDictionary *)setting;

- (void)LoadInformationFromFile:(nonnull NSString *)filePath;

- (void)Authenticate:(nonnull NSString *)publisherHashID ApplicationHashID:(nonnull NSString *)applicationHashID;

- (void)AddPlacement:(nonnull NSString *)placementHashID;

- (void)StartEngine;

- (BOOL)LogEnable;

- (VerboseType)VerboseLevel;

- (nullable FlieralPlacementManager *)GetPlacementWithHashID:(nonnull NSString *)placementHashID;

- (nullable FlieralPlacementManager *)GetPlacementFromIndex:(NSUInteger)index;

- (void)SendContentRequest:(nullable NSArray *)placementsArray AfterSeconds:(int)time;

@end
