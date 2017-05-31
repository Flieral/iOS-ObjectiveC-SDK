//
//  CacheModel.h
//  TutorialApplication
//
//  Created by Alirëza WJ Arabi on 5/31/17.
//  Copyright © 2017 Flieral Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheModel : NSObject <NSCoding>

- (nonnull instancetype)initWithModel:(nonnull NSDictionary *)model;

@property (nonatomic, strong, nullable) NSString* verb;

@property (nonatomic, strong, nullable) NSString* requestUrl;

@property (nonatomic, strong, nullable) NSDictionary* payload;

@end
