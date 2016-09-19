//
//  PlacementController.h
//  TutorialApplication
//
//  Created by Alireza Arabi on 9/17/16.
//  Copyright © 2016 Flieral Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlacementModel.h"
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, Event)
{
	PreLoad = 1,
	DidLoad = 2,
	FailedLoad = 3,
	WillAppear = 4,
	DidAppear = 5,
	WillDisappear = 6,
	DidDisappear = 7
	
} eventListener;

@interface PlacementController : NSObject

- (nullable id)initWithHashID:(nullable NSString *)hashID;

- (void)setDefaultPosition:(CGPoint) point;

- (void)setParentView:(nonnull UIView *)view;
- (void)setParentViewController:(nonnull UIViewController *)viewController;

- (void)parseBackendResponse:(nonnull NSDictionary *)response;

- (void)addOnlineContetWithFileName:(nonnull NSString *)fileName;
- (void)addOfflineContetWithFileName:(nonnull NSString *)fileName;

- (void)setPreLoadBlock:(nullable void (^)(NSDictionary * _Nonnull details)) preLoadBlock;
- (void)setDidLoadBlock:(nullable void (^)(NSDictionary * _Nonnull details)) didLoadBlock;
- (void)setFailedLoadBlock:(nullable void (^)(NSDictionary * _Nonnull details)) failedLoadBlock;
- (void)setWillAppearBlock:(nullable void (^)(NSDictionary * _Nonnull details)) willAppearBlock;
- (void)setDidAppearBlock:(nullable void (^)(NSDictionary * _Nonnull details)) didAppearBlock;
- (void)setWillDisappearBlock:(nullable void (^)(NSDictionary * _Nonnull details)) willDisappearBlock;
- (void)SetDidDisappearBlock:(nullable void (^)(NSDictionary * _Nonnull details)) didDisappearBlock;

- (void)eventListener:(Event)eventAction Details:(nonnull NSDictionary *) details;

- (void)showOnlineContent;
- (void)showOfflineContent;

- (void)hideContent;

- (void)removePlacement;

@end
