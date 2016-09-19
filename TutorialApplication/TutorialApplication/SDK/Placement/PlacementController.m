//
//  PlacementController.m
//  TutorialApplication
//
//  Created by Alireza Arabi on 9/17/16.
//  Copyright © 2016 Flieral Inc. All rights reserved.
//

#import "PlacementController.h"
#import "APIManager.h"

#define STORAGETIMERKEY		@"FlieralPlacementTimer:"
#define STORAGEHIDDENKEY	@"FlieralPlacementIsHidden:"

#define DEFAULTTIMER		600

@interface PlacementController ()

@property(nonatomic, strong) PlacementModel* placementModel;

@end

@implementation PlacementController

- (nullable id)initWithHashID:(nullable NSString *)hashID
{
	self = [super init];
	if (self)
	{
		_placementModel = [[PlacementModel alloc] initWithHashID:hashID];
	}
	return self;
}

#pragma mark - Backend Information

- (void)parseBackendResponse:(nonnull NSDictionary *)response
{
	
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

- (void)setDefaultPosition:(CGPoint) point
{
	[_placementModel setDefaultPosition:point];
}

#pragma mark - Content Setting

- (void)addOnlineContetWithFileName:(nonnull NSString *)fileName
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *filePath = [NSString stringWithFormat:@"%@/%@", [paths objectAtIndex:0],fileName];
	
	[_placementModel setOnlineModeWithContentAtURL:[NSURL fileURLWithPath:filePath]];
}

- (void)addOfflineContetWithFileName:(nonnull NSString *)fileName
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *filePath = [NSString stringWithFormat:@"%@/%@", [paths objectAtIndex:0],fileName];
	
	[_placementModel setOnlineModeWithContentAtURL:[NSURL fileURLWithPath:filePath]];
}

#pragma mark - Event Controller

- (void)eventListener:(Event)eventAction Details:(nonnull NSDictionary *) details
{
	switch (eventAction)
	{
		case PreLoad:
			_placementModel.preLoadBlock(details);
			break;

		case DidLoad:
			_placementModel.didLoadBlock(details);
			break;

		case FailedLoad:
			_placementModel.failedLoadBlock(details);
			break;
		
		case WillAppear:
			_placementModel.willAppearBlock(details);
			break;

		case DidAppear:
			_placementModel.didAppearBlock(details);
			break;

		case WillDisappear:
			_placementModel.willDisappearBlock(details);
			break;

		case DidDisappear:
			_placementModel.didDisappearBlock(details);
			break;

		default:
			break;
	}
}

- (void)setPreLoadBlock:(nullable void (^)(NSDictionary * _Nonnull details)) preLoadBlock
{
	[_placementModel setPreLoadBlock:preLoadBlock];
}

- (void)setDidLoadBlock:(nullable void (^)(NSDictionary * _Nonnull details)) didLoadBlock
{
	[_placementModel setDidLoadBlock:didLoadBlock];
}

- (void)setFailedLoadBlock:(nullable void (^)(NSDictionary * _Nonnull details)) failedLoadBlock
{
	[_placementModel setFailedLoadBlock:failedLoadBlock];
}

- (void)setWillAppearBlock:(nullable void (^)(NSDictionary * _Nonnull details)) willAppearBlock
{
	[_placementModel setWillAppearBlock:willAppearBlock];
}

- (void)setDidAppearBlock:(nullable void (^)(NSDictionary * _Nonnull details)) didAppearBlock
{
	[_placementModel setDidAppearBlock:didAppearBlock];
}

- (void)setWillDisappearBlock:(nullable void (^)(NSDictionary * _Nonnull details)) willDisappearBlock
{
	[_placementModel setWillDisappearBlock:willDisappearBlock];
}

- (void)SetDidDisappearBlock:(nullable void (^)(NSDictionary * _Nonnull details)) didDisappearBlock
{
	[_placementModel setDidDisappearBlock:didDisappearBlock];
}

#pragma mark - Shoe/Hide/Remove Actions

- (void)showOnlineContent;
{
	UIWebView *placementContent = [[UIWebView alloc] init];
	placementContent = [_placementModel getOnlineModeWithContentAtURL];
	[self showWebView:placementContent InView:_placementModel.parentView PlacementHashID:_placementModel.placementHashID];
}

- (void)showOfflineContent
{
	UIWebView *placementContent = [[UIWebView alloc] init];
	placementContent = [_placementModel getOfflineModeWithContentAtURL];
	[self showWebView:placementContent InView:_placementModel.parentView PlacementHashID:_placementModel.placementHashID];
}

- (void)hideContent
{
	[self hideWebView:_placementModel.placementView PlacementHashID:_placementModel.placementHashID];
}

- (void)showWebView:(UIWebView *)webView InView:(UIView *)view PlacementHashID:(NSString *)placementHashID
{
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	NSString *timerKey = [STORAGETIMERKEY stringByAppendingString:placementHashID];
	NSString *hiddenKey = [STORAGEHIDDENKEY stringByAppendingString:placementHashID];

	if ([ud boolForKey:hiddenKey])
	{
		if ([ud integerForKey:timerKey] > [[NSDate date] timeIntervalSince1970])
		{
			[webView setHidden:false];
			[view addSubview:webView];
			[ud setBool:false forKey:hiddenKey];
			[ud synchronize];
		}
		else
		{
			NSDictionary *dict = [NSDictionary dictionary];
			[APIManager sendReportToBackend:dict SuccessBlock:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
				
			} failedBlock:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
				
			}];
		}
	}
	else
	{
		[webView addSubview:webView];
	}
}

- (void)hideWebView:(UIWebView *)webView PlacementHashID:(NSString *)placementHashID
{
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	NSString *timerKey = [STORAGETIMERKEY stringByAppendingString:placementHashID];
	NSString *hiddenKey = [STORAGEHIDDENKEY stringByAppendingString:placementHashID];
	
	if (![ud boolForKey:hiddenKey])
	{
		int val = [[NSDate date] timeIntervalSince1970] + DEFAULTTIMER;
		[ud setInteger:val forKey:timerKey];
		[ud setBool:true forKey:hiddenKey];
		[ud synchronize];
		
		[webView setHidden:true];
	}
}

- (void)removePlacement
{
	[_placementModel.placementView removeFromSuperview];
}

@end
