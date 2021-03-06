//
//  FlieralAPIManager.m
//  TutorialApplication
//
//  Created by Alireza Arabi on 9/17/16.
//  Copyright © 2016 Flieral Inc. All rights reserved.
//

#import "FlieralAPIManager.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "PublicHeaders.h"

@implementation FlieralAPIManager

#pragma mark - Initialization

- (id)initWithBaseURL:(NSURL *)url
{
	self = [super initWithBaseURL:url];
	if(!self)
		return nil;
	
	self.requestSerializer = [AFJSONRequestSerializer serializer];
	
	[[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
	
	return self;
}

#pragma mark - Singleton Methods

+ (FlieralAPIManager *)sharedManager
{
	static dispatch_once_t pred;
	static FlieralAPIManager *_sharedManager = nil;
	
	dispatch_once(&pred, ^{
		_sharedManager = [[self alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:3015/api", SERVERADDRESS]]];
	});
	
	return _sharedManager;
}

@end
