//
//  PlacementModel.m
//  TutorialApplication
//
//  Created by Alireza Arabi on 9/17/16.
//  Copyright © 2016 Flieral Inc. All rights reserved.
//

#import "PlacementModel.h"
#import "NSQueue.h"

#define ONLINEQUEUECAPACITYKEY		3
#define OFFLINEQUEUECAPACITYKEY		2

@interface PlacementModel ()

@property (nonatomic, strong) NSQueue *onlineQueue;
@property (nonatomic, strong) NSQueue *offlineQueue;

@end

@implementation PlacementModel

#pragma mark - Placement Life Cycle

- (nullable id)initWithHashID:(nonnull NSString *)hashID
{
	self = [super init];
	if (self)
	{
		_placementHashID = hashID;
		_placementView = [[UIWebView alloc] init];
		
		_onlineQueue = [[NSQueue alloc] initWithIdentifier:_placementHashID Capacity:ONLINEQUEUECAPACITYKEY];
		_offlineQueue = [[NSQueue alloc] initWithIdentifier:_placementHashID Capacity:OFFLINEQUEUECAPACITYKEY];
		
		[_onlineQueue useAutomaticCachePolicyInOperations];
		[_offlineQueue useAutomaticCachePolicyInOperations];
	}
	return self;
}

#pragma mark - Content Setting

- (void)setOnlineModeWithContentAtURL:(nonnull NSURL *)url
{
	[_onlineQueue enqueue:url];
}

- (void)setOfflineModeWithContentAtURL:(nonnull NSURL *)url
{
	[_offlineQueue enqueue:url];
}

- (nullable UIWebView *)getOnlineModeWithContentAtURL
{
	NSURL *url = (NSURL *)[_onlineQueue dequeue];
	CGPoint point = [self checkPosition];
	[_placementView setFrame:CGRectMake(point.x, point.y, _backendSize.width, _backendSize.height)];
	[_placementView loadRequest:[NSURLRequest requestWithURL:url]];
	return _placementView;
}

- (nullable UIWebView *)getOfflineModeWithContentAtURL
{
	NSURL *url = (NSURL *)[_offlineQueue dequeue];
	CGPoint point = [self checkPosition];
	[_placementView setFrame:CGRectMake(point.x, point.y, _backendSize.width, _backendSize.height)];
	[_placementView loadRequest:[NSURLRequest requestWithURL:url]];
	return _placementView;
}

#pragma mark - Frame Setting

- (CGPoint)checkPosition
{
	CGPoint point;
	switch (_placementType)
	{
		case SmallBanner:
		
			break;

		case MediumBanner:
			
			break;

		case LargeBanner:
			
			break;

		case MediumInterstitial:
			
			break;

		case LargeInterstitial:
			
			break;

		default:
			break;
	}
	return point;
}


@end
