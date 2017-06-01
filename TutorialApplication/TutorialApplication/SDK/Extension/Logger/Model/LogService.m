//
//  LogService.m
//  WJLogCenter
//
//  Created by Alireza Arabi on 6/13/15.
//  Copyright (c) 2015 Alireza Arabi. All rights reserved.
//

#import "LogService.h"

#define TITLE		@"Title"
#define EVENT		@"Event"
#define TIME		@"Time"
#define NEWEVENT	@"NewEvent"
#define IMPORTANT	@"ImportantEvent"
#define IDENTIFIER	@"Identifier"
#define USERINFO	@"UserInfo"

#define RAND_FROM_TO(min, max) (min + arc4random_uniform(max - min + 1))

@interface LogService ()

@property (nonatomic,strong) NSString * title;
@property (nonatomic,strong) NSString * eventDescription;
@property (nonatomic,strong) NSString * timeInterval;

@property (nonatomic,strong) NSObject * userInfo;

@end

@implementation LogService

- (void)initWithTitle:(NSString *)title eventDescription:(NSString *)eventDescription UserInfo:(NSObject *)userInfo
{
	self.logServiceID       = [self createUniqueIdentifier];
	self.title              = title;
	self.eventDescription   = eventDescription;
	self.timeInterval       = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
	self.userInfo           = userInfo;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:self.title				forKey:TITLE];
	[aCoder encodeObject:self.eventDescription	forKey:EVENT];
	[aCoder encodeObject:self.timeInterval		forKey:TIME];
	[aCoder encodeObject:self.logServiceID		forKey:IDENTIFIER];
	[aCoder encodeObject:self.userInfo			forKey:USERINFO];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super init]) {
		self.title				= [aDecoder decodeObjectForKey:TITLE];
		self.eventDescription	= [aDecoder decodeObjectForKey:EVENT];
		self.timeInterval		= [aDecoder decodeObjectForKey:TIME];
		self.logServiceID		= [aDecoder decodeObjectForKey:IDENTIFIER];
		self.userInfo			= [aDecoder decodeObjectForKey:USERINFO];
	}
	return self;
}

- (NSString *)createUniqueIdentifier {
	return [NSString stringWithFormat:@"%i%f%i",RAND_FROM_TO(0, 1000),[[NSDate date] timeIntervalSince1970],RAND_FROM_TO(0, 1000)*RAND_FROM_TO(0, 1000)];
}

@end
