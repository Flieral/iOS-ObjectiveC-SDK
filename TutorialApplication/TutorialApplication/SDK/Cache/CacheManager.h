//
//  CacheManager.h
//  TutorialApplication
//
//  Created by Alirëza WJ Arabi on 5/31/17.
//  Copyright © 2017 Flieral Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CacheModel;

@interface CacheManager : NSObject

+ (nullable CacheManager *)sharedManager;

- (void)sendCacheToBackend;

- (void)addNewCacheModel:(nonnull NSDictionary *)model;

- (void)removeCacheModelAtIndex:(NSInteger)index;

- (nullable CacheModel *)getCacheModelAtIndex:(NSInteger)index;

- (nullable NSArray *)getAllCacheModels;

- (void)removeAllCacheModels;

- (void)storeCaches;

- (void)loadCaches;

@end
