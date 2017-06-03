//
//  CacheModel.m
//  TutorialApplication
//
//  Created by Alirëza WJ Arabi on 5/31/17.
//  Copyright © 2017 Flieral Inc. All rights reserved.
//

#import "CacheModel.h"

@implementation CacheModel

- (nonnull instancetype)initWithModel:(nonnull NSDictionary *)model
{
    self = [super init];
    if (self)
    {
        _verb       = [model valueForKey:@"method"];
        _requestUrl = [model valueForKey:@"url"];
        if ([model valueForKey:@"body"])
            _payload    = [model valueForKey:@"body"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.verb         forKey:@"VERB"];
    [encoder encodeObject:self.requestUrl   forKey:@"REQUESTURL"];
    [encoder encodeObject:self.payload      forKey:@"PAYLOAD"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if(self)
    {
        self.verb       = [decoder decodeObjectForKey:@"VERB"];
        self.requestUrl = [decoder decodeObjectForKey:@"REQUESTURL"];
        self.payload    = [decoder decodeObjectForKey:@"PAYLOAD"];
    }
    return self;
}

@end
