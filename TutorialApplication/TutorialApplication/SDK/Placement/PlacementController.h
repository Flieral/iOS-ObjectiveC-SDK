//
//  PlacementController.h
//  TutorialApplication
//
//  Created by Alireza Arabi on 9/17/16.
//  Copyright © 2016 Flieral Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PlacementController : NSObject

- (nullable id)init;

- (void)setParentView:(nonnull UIView *)view;
- (void)setParentViewController:(nonnull UIViewController *)viewController;

- (void)setPosition:(CGPoint) point;
- (void)setSize:(CGSize) size;
- (void)setRect:(CGRect) rect;

- (void)setContentFromFileName:(nonnull NSString *)fileName;

@end
