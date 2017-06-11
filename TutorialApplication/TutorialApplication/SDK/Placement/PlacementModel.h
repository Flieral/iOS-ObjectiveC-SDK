//
//  PlacementModel.h
//  TutorialApplication
//
//  Created by Alireza Arabi on 9/17/16.
//  Copyright © 2016 Flieral Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PlacementModel : NSObject <NSCoding>

@property (nonatomic, strong) NSString  * _Nonnull placementHashID;
@property (nonatomic, strong) NSString  * _Nonnull applicationHashID;
@property (nonatomic, strong) NSString  * _Nonnull publisherHashID;
@property (nonatomic, strong) NSString  * _Nonnull fileURL;

@property (nonatomic, strong) NSString  * _Nonnull subcampaignHashID;
@property (nonatomic, strong) NSString  * _Nonnull campaignHashID;
@property (nonatomic, strong) NSString  * _Nonnull announcerHashID;

@property (nonatomic, strong) NSURL     * _Nonnull contentURL;

- (nullable id)initWithModel:(nonnull NSMutableDictionary *)modelInstance;

- (nullable NSMutableDictionary *)getAnnouncerModel;
- (nullable NSMutableDictionary *)getPublisherModel;

@end
