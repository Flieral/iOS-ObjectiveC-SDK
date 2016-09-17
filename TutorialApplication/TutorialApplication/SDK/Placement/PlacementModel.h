//
//  PlacementModel.h
//  TutorialApplication
//
//  Created by Alireza Arabi on 9/17/16.
//  Copyright © 2016 Flieral Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PlacementModel : NSObject

- (nullable id)initWithParentView:(nonnull UIView *)parentView;

- (void)setParentView:(nonnull UIView *)parentView;

- (void)fillWithContentAtURL:(nonnull NSURL *)url;

- (void)setPosition:(CGPoint) point;
- (void)setSize:(CGSize) size;
- (void)setRect:(CGRect) rect;

@end
