//
//  PlacementHelper.m
//  TutorialApplication
//
//  Created by Alirëza WJ Arabi on 6/1/17.
//  Copyright © 2017 Flieral Inc. All rights reserved.
//

#import "PlacementHelper.h"
#import "PublicHeaders.h"

@interface PlacementHelper ()

@end

@implementation PlacementHelper

#pragma mark - Shared Instance Singelton

+ (nullable PlacementHelper *)sharedHelper
{
    static PlacementHelper* sharedService = nil;
    static dispatch_once_t  onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedService = [self new];
    });
    
    return sharedService;
}

#pragma mark - Placement Helper

- (void)saveTimerForContent:(nonnull NSString *)contentHashId
{
    NSString *key           = [FLCONTENTTIMERKEY stringByAppendingString:contentHashId];
    NSMutableArray *array   = [NSMutableArray array];
    NSUserDefaults *ud      = [NSUserDefaults standardUserDefaults];
    NSNumber *date          = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
    
    [ud setObject:date forKey:key];
    
    array = [ud objectForKey:FLCONTENTTIMERKEY];
    [array addObject:key];
    [ud setObject:array forKey:FLCONTENTTIMERKEY];
    
    [ud synchronize];
}

- (nullable NSNumber *)loadTimerForContent:(nonnull NSString *)contentHashId
{
    NSUserDefaults *ud  = [NSUserDefaults standardUserDefaults];
    NSNumber *date      = [ud objectForKey:[FLCONTENTTIMERKEY stringByAppendingString:contentHashId]];
    return date;
}

- (void)removeTimerForContent:(nonnull NSString *)contentHashId
{
    NSString *key           = [FLCONTENTTIMERKEY stringByAppendingString:contentHashId];
    NSMutableArray *array   = [NSMutableArray array];
    NSUserDefaults *ud      = [NSUserDefaults standardUserDefaults];

    [ud removeObjectForKey:key];
    
    array = [ud objectForKey:FLCONTENTTIMERKEY];
    [array removeObject:key];
    [ud setObject:array forKey:FLCONTENTTIMERKEY];
    
    [ud synchronize];
}

#pragma mark - File Manager

- (void)removeFileAtPath:(nonnull NSString *)filePath
{
    NSError *err;
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:&err];
}

- (BOOL)checkForFileExistsAtPath:(nonnull NSString *)filePath
{
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

#pragma mark - Cache Cleaner

- (void)startCleaner
{
    NSURL *documentsDirectoryURL    = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    NSMutableArray *array           = [NSMutableArray array];
    NSUserDefaults *ud              = [NSUserDefaults standardUserDefaults];
    array                           = [ud objectForKey:FLCONTENTTIMERKEY];

    double threshold = [[NSDate date] timeIntervalSince1970];
    for (int i = 0; i < [array count]; i++)
    {
        NSString *key = [array objectAtIndex:i];
        if ([[self loadTimerForContent:key] doubleValue] + FLCONTENTTIMER >= threshold)
        {
            [self removeTimerForContent:key];
            [self removeFileAtPath:[[documentsDirectoryURL URLByAppendingPathComponent:[[key componentsSeparatedByString:@":"] lastObject]] path]];
        }
    }
}

@end
