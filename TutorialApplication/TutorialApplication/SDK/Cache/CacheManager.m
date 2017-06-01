//
//  CacheManager.m
//  TutorialApplication
//
//  Created by Alirëza WJ Arabi on 5/31/17.
//  Copyright © 2017 Flieral Inc. All rights reserved.
//

#import "CacheManager.h"
#import "PublicHeaders.h"
#import "CacheModel.h"
#import "RestAPI.h"

@interface CacheManager ()

@property (nonatomic, strong) NSMutableArray *cacheArray;

@end

@implementation CacheManager

#pragma mark - Shared Instance Singelton

+ (nullable CacheManager *)sharedManager
{
    static CacheManager*    sharedService = nil;
    static dispatch_once_t  onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedService = [self new];
        sharedService.cacheArray = [NSMutableArray array];
    });
    
    return sharedService;
}

#pragma mark - Send to Backend

- (void)sendCacheToBackend
{
    [self storeCaches];
    [self loadCaches];
    
    NSArray *tempArray = [self getAllCacheModels];
    [self removeAllCacheModels];
    
    for (int i = 0; i < [tempArray count]; i++)
    {
        CacheModel *cache = [tempArray objectAtIndex:i];
        
        if ([cache.verb isEqualToString:@"GET"])
        {
            [[RestAPI sharedService] getMethodWithQueryString:cache.requestUrl Parameters:cache.payload Progress:nil SuccessBlock:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                
            } failedBlock:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
                
            }];
        }
        else if ([cache.verb isEqualToString:@"PUT"])
        {
            [[RestAPI sharedService] putMethodWithQueryString:cache.requestUrl Parameters:cache.payload SuccessBlock:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                
            } failedBlock:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
                
            }];
        }
        else if ([cache.verb isEqualToString:@"POST"])
        {
            [[RestAPI sharedService] postMethodWithQueryString:cache.requestUrl Parameters:cache.payload Progress:nil SuccessBlock:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                
            } failedBlock:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
                
            }];
        }
        else if ([cache.verb isEqualToString:@"DELETE"])
        {
            [[RestAPI sharedService] deleteMethodWithQueryString:cache.requestUrl Parameters:cache.payload SuccessBlock:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                
            } failedBlock:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
                
            }];
        }
    }
    [self storeCaches];
    [self loadCaches];
}

#pragma mark - Cache Life Cycle

- (void)addNewCacheModel:(nonnull NSDictionary *)model
{
    CacheModel *cache = [[CacheModel alloc] initWithModel:model];
    [_cacheArray addObject:cache];
}

- (void)removeCacheModelAtIndex:(NSInteger)index
{
    if (index >= 0 || index < [_cacheArray count])
        [_cacheArray removeObjectAtIndex:index];
}

- (nullable CacheModel *)getCacheModelAtIndex:(NSInteger)index
{
    if (index >= 0 || index < [_cacheArray count])
        return [_cacheArray objectAtIndex:index];
    return nil;
}

- (nullable NSArray *)getAllCacheModels
{
    return _cacheArray;
}

- (void)removeAllCacheModels
{
    [_cacheArray removeAllObjects];
}

#pragma mark - Cache Storage

- (void)storeCaches
{
    NSData *encodedObject   = [NSKeyedArchiver archivedDataWithRootObject:_cacheArray];
    NSUserDefaults *ud      = [NSUserDefaults standardUserDefaults];
    
    [ud setObject:encodedObject     forKey:FLSTORAGESDKCACHEKEY];
    [ud synchronize];
    
    [_cacheArray removeAllObjects];
}

- (void)loadCaches
{
    NSUserDefaults *ud      = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject   = [ud objectForKey:FLSTORAGESDKCACHEKEY];

    [_cacheArray removeAllObjects];
    
    _cacheArray = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
}

@end
