//
//  PlacementController.m
//  TutorialApplication
//
//  Created by Alireza Arabi on 9/17/16.
//  Copyright © 2016 Flieral Inc. All rights reserved.
//

#import "PlacementController.h"
#import "PlacementModel.h"

@interface PlacementController ()

@property(nonatomic, strong) UIView* parentView;
@property(nonatomic, strong) PlacementModel* placementModel;

@end

@implementation PlacementController

- (nullable id)init
{
	self = [super init];
	if (self)
	{
		
	}
	return self;
}

#pragma mark - Parent Setting

- (void)setParentView:(nonnull UIView *)view
{
	[_placementModel setParentView:view];
}

- (void)setParentViewController:(nonnull UIViewController *)viewController
{
	[_placementModel setParentView:viewController.view];
}

#pragma mark - Frame Setting

- (void)setPosition:(CGPoint) point
{
	[_placementModel setPosition:point];
}

- (void)setSize:(CGSize) size
{
	[_placementModel setSize:size];
}

- (void)setRect:(CGRect) rect
{
	[_placementModel setRect:rect];
}

#pragma mark - Content Setting

- (void)setContentFromFileName:(nonnull NSString *)fileName
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *filePath = [NSString stringWithFormat:@"%@/%@", [paths objectAtIndex:0],fileName];

	[_placementModel fillWithContentAtURL:[NSURL fileURLWithPath:filePath]];
}

@end
