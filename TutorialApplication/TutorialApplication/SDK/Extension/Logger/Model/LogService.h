//
//  LogService.h
//  WJLogCenter
//
//  Created by Alireza Arabi on 6/13/15.
//  Copyright (c) 2015 Alireza Arabi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LogService : NSObject

@property (nonatomic,strong) NSString *logServiceID;

- (void)initWithTitle:(NSString *)title eventDescription:(NSString *)eventDescription UserInfo:(NSObject *)userInfo;

- (NSString *)title;

- (NSString *)eventDescription;

- (NSString *)timeInterval;

@end
