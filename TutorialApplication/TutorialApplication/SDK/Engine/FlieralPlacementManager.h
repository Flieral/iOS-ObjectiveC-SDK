//
//  FlieralPlacementManager.h
//  TutorialApplication
//
//  Created by Alireza Arabi on 9/17/16.
//  Copyright © 2016 Flieral Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FlieralPlacementManager : NSObject

- (nullable id)initWithHashID:(nullable NSString *)hashID;

- (void)SetDefaultPosition:(CGPoint)point;
- (void)SetParentView:(nonnull UIView *)parentView;

- (void)SetPreLoadBlock:(nullable void (^)(NSDictionary * _Nonnull details)) preLoadBlock;
- (void)SetDidLoadBlock:(nullable void (^)(NSDictionary * _Nonnull details)) didLoadBlock;
- (void)SetFailedLoadBlock:(nullable void (^)(NSDictionary * _Nonnull details)) failedLoadBlock;
- (void)SetWillAppearBlock:(nullable void (^)(NSDictionary * _Nonnull details)) willAppearBlock;
- (void)SetDidAppearBlock:(nullable void (^)(NSDictionary * _Nonnull details)) didAppearBlock;
- (void)SetWillDisappearBlock:(nullable void (^)(NSDictionary * _Nonnull details)) willDisappearBlock;
- (void)SetDidDisappearBlock:(nullable void (^)(NSDictionary * _Nonnull details)) didDisappearBlock;

- (void)Hide;
- (void)Show;

@end
