//
//  PlacementModel.m
//  TutorialApplication
//
//  Created by Alireza Arabi on 9/17/16.
//  Copyright © 2016 Flieral Inc. All rights reserved.
//

#import "PlacementModel.h"

@interface PlacementModel ()

@property (nonatomic, strong) UIView *parentView;
@property (nonatomic, strong) UIWebView *placementView;

@end

@implementation PlacementModel

#pragma mark - Placement Life Cycle

- (nullable id)initWithParentView:(nonnull UIView *)parentView
{
	self = [super init];
	if (self)
	{
		_placementView = [[UIWebView alloc] init];
		_parentView = parentView;
	}
	return self;
}

#pragma mark - Parent View Setting

- (void)setParentView:(nonnull UIView *)parentView
{
	_parentView = parentView;
}

#pragma mark - Content Setting

- (void)fillWithContentAtURL:(nonnull NSURL *)url
{
	[_placementView loadRequest:[NSURLRequest requestWithURL:url]];
}

#pragma mark - Frame Setting

- (void)setPosition:(CGPoint) point
{
	[_placementView setFrame:CGRectMake(point.x, point.y, _placementView.frame.size.width, _placementView.frame.size.height)];
}

- (void)setSize:(CGSize) size
{
	[_placementView setFrame:CGRectMake(_placementView.frame.origin.x, _placementView.frame.origin.y, size.width, size.height)];
}

- (void)setRect:(CGRect) rect
{
	[_placementView setFrame:rect];
}

@end
