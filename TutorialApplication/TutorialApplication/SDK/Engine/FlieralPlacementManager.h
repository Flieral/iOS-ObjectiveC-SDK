//
//  FlieralPlacementManager.h
//  TutorialApplication
//
//  Created by Alireza Arabi on 9/17/16.
//  Copyright © 2016 Flieral Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, StatusType)
{
    Enable      = 1,
    Disable     = 2
    
} placementStatus;

typedef NS_ENUM(NSInteger, PriorityType)
{
    LowPriority     = 1,
    AveragePriority = 2,
    HighPriority    = 3
    
} priorityState;

typedef NS_ENUM(NSInteger, StyleType)
{
    SmallBanner         = 1,
    MediumBanner        = 2,
    LargeBanner         = 3,
    MediumInterstitial  = 4,
    LargeInterstitial   = 5
    
} style;

typedef NS_ENUM(NSInteger, Event)
{
    PreLoad         = 1,
    DidLoad         = 2,
    FailedLoad      = 3,
    WillAppear      = 4,
    DidAppear       = 5,
    WillDisappear   = 6,
    DidDisappear    = 7
    
} eventListener;

@class PlacementModel;

@interface FlieralPlacementManager : NSObject

@property (nonatomic, strong, nonnull) NSString     * placementHashID;
@property (nonatomic, strong, nonnull) NSDictionary * instanceObject;

- (nullable id)initWithPlacementHashId:(nonnull NSString *)placementHashId;

- (void)FillPlacementInstance:(nonnull NSDictionary *)modelInstance;

- (void)AddPlacementOnlineContent:(nonnull PlacementModel *)modelInstance;
- (void)AddPlacementOfflineContent:(nonnull PlacementModel *)modelInstance;

- (void)SetParentView:(nonnull UIView *)view;
- (void)SetParentViewController:(nonnull UIViewController *)viewController;

- (void)SetPreLoadBlock:(nullable void (^)(NSDictionary         * _Nonnull details)) preLoadBlock;
- (void)SetDidLoadBlock:(nullable void (^)(NSDictionary         * _Nonnull details)) didLoadBlock;
- (void)SetFailedLoadBlock:(nullable void (^)(NSDictionary      * _Nonnull details)) failedLoadBlock;
- (void)SetWillAppearBlock:(nullable void (^)(NSDictionary      * _Nonnull details)) willAppearBlock;
- (void)SetDidAppearBlock:(nullable void (^)(NSDictionary       * _Nonnull details)) didAppearBlock;
- (void)SetWillDisappearBlock:(nullable void (^)(NSDictionary   * _Nonnull details)) willDisappearBlock;
- (void)SetDidDisappearBlock:(nullable void (^)(NSDictionary    * _Nonnull details)) didDisappearBlock;

- (void)Hide;
- (void)Show;

- (PriorityType)GetPlacementPriority;
- (StatusType)GetPlacementStatus;

@end
