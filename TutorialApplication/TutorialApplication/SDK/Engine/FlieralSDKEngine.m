//
//  FlieralSDKEngine.m
//  TutorialApplication
//
//  Created by Alireza Arabi on 9/17/16.
//  Copyright © 2016 Flieral Inc. All rights reserved.
//

#import "FlieralSDKEngine.h"
#import "FlieralPlacementManager.h"
#import "APIManager.h"
#import "MonitorManager.h"
#import "UserManager.h"
#import "PlacementModel.h"
#import "PublicHeaders.h"
#import "CacheManager.h"
#import "Reachability.h"

@interface FlieralSDKEngine () <MonitorManagerDelegate, UserManagerDelegate>
{
    Reachability *internetReachabilityChecker;
}

@property (nonatomic, strong) NSMutableArray *placementHashIdArray;
@property (nonatomic, strong) NSMutableArray *placementManagerArray;

@property (nonatomic, strong) NSDictionary *monitorData;
@property (nonatomic, strong) NSDictionary *settingData;

@property (nonatomic, strong) MonitorManager *monitorManager;
@property (nonatomic, strong) UserManager *userManager;

@property (nonatomic) BOOL readyForStart;
@property (nonatomic) BOOL readyForUse;
@property (nonatomic) BOOL readyForAlgorithm;
@property (nonatomic) BOOL readyForWork;

@property (nonatomic) BOOL debugEnable;
@property (nonatomic) BOOL logEnable;

@property (nonatomic) BOOL pingReady;
@property (nonatomic) BOOL userReady;

@end

@implementation FlieralSDKEngine

#pragma mark - Shared Instance Singelton

+ (nullable FlieralSDKEngine *)SDKEngine:(nullable NSDictionary *)setting
{
	static FlieralSDKEngine* sharedService = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
        sharedService = [self new];
		
		sharedService.placementHashIdArray = [NSMutableArray array];
        sharedService.placementManagerArray = [NSMutableArray array];
        
        sharedService.monitorData = [NSDictionary dictionary];
        sharedService.settingData = [NSDictionary dictionary];
        
		sharedService.readyForUse   = false;
		sharedService.readyForStart = false;
        sharedService.readyForAlgorithm = false;
        sharedService.readyForWork  = false;
		
        sharedService.pingReady = false;
        sharedService.userReady = false;
        
        sharedService.userManager = [[UserManager alloc] init];
        [sharedService.userManager startSetting];
        
		sharedService.monitorManager = [[MonitorManager alloc] init];
		[sharedService.monitorManager startPinging];
        
        sharedService.debugEnable = false;
        #ifndef NDEBUG
            sharedService.debugEnable = true;
        #endif

        sharedService.logEnable = false;
        if ([[setting valueForKey:@"logEnable"] isEqualToString:@"true"])
            sharedService.logEnable = true;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startMonitorAndSetting) name:UIApplicationWillEnterForegroundNotification object:nil];
	});
	
	return sharedService;
}

- (BOOL)LogEnable
{
    return _logEnable;
}

#pragma mark - Authentication

- (void)Authenticate:(nonnull NSString *)publisherHashID ApplicationHashID:(nonnull NSString *)applicationHashID
{
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	[ud setValue:publisherHashID forKey:FLPUBLISHERHASHIDKEY];
    [ud setValue:applicationHashID forKey:FLAPPLICATIONHASHIDKEY];
	[ud synchronize];
}

- (NSDictionary *)GetAuthenticationCredential
{
    NSDictionary *dict = [NSDictionary dictionary];
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [dict setValue:[ud valueForKey:FLPUBLISHERHASHIDKEY] forKey:FLPUBLISHERHASHIDKEY];
    [dict setValue:[ud valueForKey:FLAPPLICATIONHASHIDKEY] forKey:FLAPPLICATIONHASHIDKEY];
	return dict;
}

#pragma mark - Add Placement

- (void)AddPlacement:(nonnull NSString *)placementHashID
{
    [_placementHashIdArray addObject:placementHashID];

    FlieralPlacementManager *placementManager = [[FlieralPlacementManager alloc] initWithPlacementHashId:placementHashID];
    [_placementManagerArray addObject:placementManager];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:_placementHashIdArray forKey:FLPLACEMENTHASHIDKEY];
    [ud synchronize];
}

- (NSMutableArray *)GetPlacements
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud objectForKey:FLPLACEMENTHASHIDKEY];
}

#pragma mark - Start Flieral Engine

- (void)StartEngine
{
    internetReachabilityChecker = [Reachability reachabilityForInternetConnection];
    
    NetworkStatus status = [internetReachabilityChecker currentReachabilityStatus];
    [internetReachabilityChecker startNotifier];
    
    if (status != NotReachable)
    {
        if (![_userManager checkUserHashID])
        {
            [APIManager getUserHashIDWithSuccessBlock:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
                if (httpResponse.statusCode == 200)
                {
                    NSString *userhashId = [NSString stringWithString:[responseObject valueForKey:@"response"]];
                    [_userManager setUserHashID:userhashId];
                    _readyForStart = true;
                    [self ReadyForStart];
                }
            } failedBlock:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
                _readyForStart = false;
            }];
        }
        else
        {
            _readyForStart = true;
            [self ReadyForStart];
        }
    }
    else
    {
        // offline placement manager
    }
}

- (void)ReadyForStart
{
    if (_readyForStart)
    {
        [APIManager sendAuthenticationToBackend:[self GetAuthenticationCredential] SuccessBlock:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
            if (httpResponse.statusCode == 200)
            {
                NSArray *placementsInfoArray = (NSArray *)responseObject;
                for (int i = 0; i < [placementsInfoArray count]; i++)
                {
                    NSDictionary *plModel = (NSDictionary *)[placementsInfoArray objectAtIndex:i];
                    FlieralPlacementManager *plManager = [self GetPlacementWithHashID:[plModel valueForKey:@"id"]];
                    [plManager FillPlacementInstance:plModel];
                }
                    
                _readyForUse = true;
                [self ReadyForUse];
            }
        } failedBlock:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
            _readyForUse = false;
        }];
    }
}

- (void)ReadyForUse
{
    if (_readyForUse)
    {
        _settingData = [_userManager getUserSetting];
        _monitorData = [_monitorManager getMonitorSetting];
        NSDictionary *dict = [NSDictionary dictionary];
        [dict setValue:_settingData forKey:@"applicationModel"];
        [dict setValue:_monitorData forKey:@"pingModel"];
        [dict setValue:[_userManager getUserHashID] forKey:@"userId"];
        
        [APIManager sendUserInformation:dict SuccessBlock:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
            if (httpResponse.statusCode == 200)
            {
                _readyForAlgorithm = true;
                [self StartAlgorithm];
            }
        } failedBlock:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
            _readyForAlgorithm = false;
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [[CacheManager sharedManager] sendCacheToBackend];
        });
    }
}

#pragma mark - Content Delivery Algorithm

- (void)StartAlgorithm
{
    NSMutableArray *lowArray = [NSMutableArray array];
    NSMutableArray *averageArray = [NSMutableArray array];
    NSMutableArray *highArray = [NSMutableArray array];
    NSMutableArray *deleteArray = [NSMutableArray array];
    
    if (_readyForAlgorithm)
    {
        for (int i = 0; i < [_placementManagerArray count]; i++)
        {
            FlieralPlacementManager *plManager = [_placementManagerArray objectAtIndex:i];
            if ([plManager GetPlacementStatus] == Enable)
            {
                if ([plManager GetPlacementPriority] == HighPriority)
                    [highArray addObject:plManager.instanceObject];
                else if ([plManager GetPlacementPriority] == AveragePriority)
                    [averageArray addObject:plManager.instanceObject];
                else if ([plManager GetPlacementPriority] == LowPriority)
                    [lowArray addObject:plManager.instanceObject];
            }
            else
                [deleteArray addObject:[NSNumber numberWithInt:i]];
        }
        
        for (int i = 0; i < [deleteArray count]; i++)
        {
            [_placementManagerArray removeObjectAtIndex:(int)[deleteArray objectAtIndex:i]];
            [_placementHashIdArray removeObjectAtIndex:(int)[deleteArray objectAtIndex:i]];
        }
        
        [self SendContentRequest:highArray AfterSeconds:0];
        [self SendContentRequest:averageArray AfterSeconds:1];
        [self SendContentRequest:lowArray AfterSeconds:2];
    }
}

- (void)SendContentRequest:(NSArray *)array AfterSeconds:(int)time
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, time * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [APIManager sendRequestForContent:array SuccessBlock:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
            if (httpResponse.statusCode == 200)
            {
                NSDictionary *dict = (NSDictionary *)responseObject;
                NSString *placementHashId = [dict valueForKey:@"placementId"];
                NSArray *onlineArray = [dict objectForKey:@"onlineContent"];
                NSArray *offlineArray = [dict objectForKey:@"offlineContent"];
                FlieralPlacementManager *plManager = [self GetPlacementWithHashID:placementHashId];
                for (int i = 0; i < [onlineArray count]; i++)
                {
                    PlacementModel *model = [[PlacementModel alloc] initWithModel:[onlineArray objectAtIndex:i]];
                    [plManager AddPlacementOnlineContent:model];
                }
                for (int i = 0; i < [offlineArray count]; i++)
                {
                    PlacementModel *model = [[PlacementModel alloc] initWithModel:[offlineArray objectAtIndex:i]];
                    [plManager AddPlacementOfflineContent:model];
                }
                _readyForWork = true;
            }
        } failedBlock:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {

        }];
    });
}

#pragma mark - Placement Manager

- (nullable FlieralPlacementManager *)GetPlacementWithHashID:(nonnull NSString *)placementHashID;
{
    if (_readyForWork || _readyForStart)
    {
        for (int index = 0; index < [_placementHashIdArray count]; index++)
            if ([[_placementHashIdArray objectAtIndex:index] isEqualToString:placementHashID])
                return [_placementManagerArray objectAtIndex:index];
    }
    return nil;
}

#pragma mark - User Delegate and Monitor Delegate

- (void)startMonitorAndSetting
{
    _pingReady = false;
    _userReady = false;
    [_monitorManager startPinging];
    [_userManager startSetting];
}

- (void)monitorResponse:(nonnull NSDictionary *)monitor
{
    _monitorData = monitor;
    _pingReady = true;
    [self sendNewInformation];
}

- (void)settingResponse:(nonnull NSDictionary *)setting
{
    _settingData = setting;
    _userReady = true;
    [self sendNewInformation];
}

- (void)sendNewInformation
{
    if (_pingReady && _userReady)
    {
        _settingData = [_userManager getUserSetting];
        _monitorData = [_monitorManager getMonitorSetting];
        NSDictionary *dict = [NSDictionary dictionary];
        [dict setValue:_settingData forKey:@"applicationModel"];
        [dict setValue:_monitorData forKey:@"pingModel"];
        [dict setValue:[_userManager getUserHashID] forKey:@"userId"];
        
        [APIManager sendUserInformation:dict SuccessBlock:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
            if (httpResponse.statusCode == 200)
            {
                _pingReady = false;
                _userReady = false;
            }
        } failedBlock:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
            
        }];
    }
}

@end
