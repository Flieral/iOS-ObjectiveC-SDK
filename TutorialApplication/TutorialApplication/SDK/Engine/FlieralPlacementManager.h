//
//  FlieralPlacementManager.h
//  TutorialApplication
//
//  Created by Alireza Arabi on 9/17/16.
//  Copyright © 2016 Flieral Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlieralPlacementManager : NSObject

- (void)SetPreLoadBlock:(nullable void (^)(NSDictionary * _Nonnull details)) preLoadBlock;
- (void)SetDidLoadBlock:(nullable void (^)(NSDictionary * _Nonnull details)) preLoadBlock;
- (void)SetFailedLoadBlock:(nullable void (^)(NSDictionary * _Nonnull details)) failedLoadBlock;
- (void)SetWillAppearBlock:(nullable void (^)(NSDictionary * _Nonnull details)) willAppearBlock;
- (void)SetDidAppearBlock:(nullable void (^)(NSDictionary * _Nonnull details)) didAppearLoadBlock;
- (void)SetWillDisappearBlock:(nullable void (^)(NSDictionary * _Nonnull details)) willDisappearBlock;
- (void)SetDidDisappearBlock:(nullable void (^)(NSDictionary * _Nonnull details)) didDisappearLoadBlock;

- (void)Hide;
- (void)Show;

@end
