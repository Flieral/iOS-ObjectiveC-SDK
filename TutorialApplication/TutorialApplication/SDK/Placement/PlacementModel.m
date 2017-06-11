//
//  PlacementModel.m
//  TutorialApplication
//
//  Created by Alireza Arabi on 9/17/16.
//  Copyright © 2016 Flieral Inc. All rights reserved.
//

#import "PlacementModel.h"

@implementation PlacementModel

#pragma mark - Placement Life Cycle

- (nullable id)initWithModel:(nonnull NSMutableDictionary *)modelInstance
{
	self = [super init];
	if (self)
	{
		_placementHashID    = [[modelInstance valueForKey:@"publisherInfo"] valueForKey:@"placementHashId"];
        _applicationHashID  = [[modelInstance valueForKey:@"publisherInfo"] valueForKey:@"applicationHashId"];
        _publisherHashID    = [[modelInstance valueForKey:@"publisherInfo"] valueForKey:@"publisherHashId"];
        _fileURL            = [[modelInstance valueForKey:@"publisherInfo"] valueForKey:@"fileURL"];
        
        _subcampaignHashID  = [[modelInstance valueForKey:@"announcerInfo"] valueForKey:@"subcampaignHashId"];
        _campaignHashID     = [[modelInstance valueForKey:@"announcerInfo"] valueForKey:@"campaignHashId"];
        _announcerHashID    = [[modelInstance valueForKey:@"announcerInfo"] valueForKey:@"announcerHashId"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.placementHashID      forKey:@"PLACEMENTHASHID"];
    [encoder encodeObject:self.applicationHashID    forKey:@"APPLICATIONHASHID"];
    [encoder encodeObject:self.publisherHashID      forKey:@"PUBLISHERHASHID"];
    [encoder encodeObject:self.fileURL              forKey:@"FILEURL"];
    [encoder encodeObject:self.subcampaignHashID    forKey:@"SUBCAMPAIGNHASHID"];
    [encoder encodeObject:self.campaignHashID       forKey:@"CAMPAIGNHASHID"];
    [encoder encodeObject:self.announcerHashID      forKey:@"ANNOUNCERHASHID"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if(self)
    {
        self.placementHashID      = [decoder decodeObjectForKey:@"PLACEMENTHASHID"];
        self.applicationHashID    = [decoder decodeObjectForKey:@"APPLICATIONHASHID"];
        self.publisherHashID      = [decoder decodeObjectForKey:@"PUBLISHERHASHID"];
        self.fileURL              = [decoder decodeObjectForKey:@"FILEURL"];
        self.subcampaignHashID    = [decoder decodeObjectForKey:@"SUBCAMPAIGNHASHID"];
        self.campaignHashID       = [decoder decodeObjectForKey:@"CAMPAIGNHASHID"];
        self.announcerHashID      = [decoder decodeObjectForKey:@"ANNOUNCERHASHID"];
    }
    return self;
}

#pragma mark - Dictionary Format of Data

- (nullable NSMutableDictionary *)getAnnouncerModel
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:_subcampaignHashID   forKey:@"subcampaignHashId"];
    [dict setValue:_campaignHashID      forKey:@"campaignHashId"];
    [dict setValue:_announcerHashID     forKey:@"announcerHashId"];
    return dict;
}

- (nullable NSMutableDictionary *)getPublisherModel
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:_placementHashID     forKey:@"placementHashId"];
    [dict setValue:_applicationHashID   forKey:@"applicationHashId"];
    [dict setValue:_publisherHashID     forKey:@"publisherHashId"];
    return dict;
}

@end
