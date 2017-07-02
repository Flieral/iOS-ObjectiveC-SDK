//
//  FlieralSDKEngine.m
//  TutorialApplication
//
//  Created by Alireza Arabi on 9/17/16.
//  Copyright © 2016 Flieral Inc. All rights reserved.
//

#import "FlieralSDKEngine.h"
#import "FlieralPlacementManager.h"
#import "PlacementHelper.h"
#import "PlacementModel.h"
#import "MonitorManager.h"
#import "PublicHeaders.h"
#import "CacheManager.h"
#import "Reachability.h"
#import "UserManager.h"
#import "APIManager.h"
#import "LogCenter.h"

@interface FlieralSDKEngine () <MonitorManagerDelegate, UserManagerDelegate>
{
    Reachability *internetReachabilityChecker;
}

@property (nonatomic, strong, nullable) MonitorManager    * monitorManager;
@property (nonatomic, strong, nullable) UserManager       * userManager;

@property (nonatomic, strong, nullable) NSMutableArray * placementHashIdArray;
@property (nonatomic, strong, nullable) NSMutableArray * placementManagerArray;

@property (nonatomic, strong, nullable) NSMutableDictionary * monitorData;
@property (nonatomic, strong, nullable) NSMutableDictionary * settingData;

@property (nonatomic) BOOL readyForStart;
@property (nonatomic) BOOL readyForUse;
@property (nonatomic) BOOL readyForAlgorithm;
@property (nonatomic) BOOL readyForWork;

@property (nonatomic) VerboseType verboseLevel;

@property (nonatomic) BOOL logEnable;

@property (nonatomic) BOOL pingReady;
@property (nonatomic) BOOL userReady;

@end

@implementation FlieralSDKEngine

#pragma mark - Shared Instance Singelton

+ (nullable FlieralSDKEngine *)SDKEngine
{
	static FlieralSDKEngine* sharedService = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
        sharedService = [self new];
		
        [[PlacementHelper sharedHelper] startCleaner];
        
		sharedService.placementHashIdArray  = [NSMutableArray array];
        sharedService.placementManagerArray = [NSMutableArray array];
        
        sharedService.monitorData = [NSMutableDictionary dictionary];
        sharedService.settingData = [NSMutableDictionary dictionary];
        
		sharedService.readyForUse       = false;
		sharedService.readyForStart     = false;
        sharedService.readyForAlgorithm = false;
        sharedService.readyForWork      = false;
		
        sharedService.pingReady = false;
        sharedService.userReady = false;
        
        sharedService.userManager = [[UserManager alloc] init];
        [sharedService.userManager startSetting];
        
		sharedService.monitorManager = [[MonitorManager alloc] init];
		[sharedService.monitorManager startPinging];
        
        sharedService.verboseLevel = None;
        #ifndef NDEBUG
            sharedService.verboseLevel = _V;
        #endif

        sharedService.logEnable = false;
	});
	
	return sharedService;
}

- (void)AddSetting:(nullable NSMutableDictionary *)setting
{
    if ([[setting valueForKey:@"logEnable"] isEqualToString:@"true"])
    {
        [LogCenter SetEnableLogServiceManager:YES];
        [LogCenter SetEnableDeveloperLogs:YES];
        _logEnable = true;
        
        switch ([[setting valueForKey:@"verboseLevel"] intValue]) {
            case _V:
                _verboseLevel = _V;
                break;
            case _VV:
                _verboseLevel = _VV;
                break;
            case _VVV:
                _verboseLevel = _VVV;
                break;
            default:
                _verboseLevel = _V;
                break;
        }
    }
}

- (BOOL)LogEnable
{
    return _logEnable;
}

- (VerboseType)VerboseLevel
{
    return _verboseLevel;
}

#pragma mark - File Loading

- (void)LoadInformationFromFile:(nonnull NSString *)filePath
{
    if (_logEnable)
        [LogCenter NewLogTitle:@"Load File" LogDescription:@"Start Processing Data From File" UserInfo:nil];
    
    NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    [self Authenticate:[dict objectForKey:@"accountHashId"] ApplicationHashID:[dict objectForKey:@"applicationHashId"]];
    
    NSArray *placementArray = (NSArray *) [dict objectForKey:@"placements"];
    
    for (int i = 0; i < [placementArray count]; i++)
        [self AddPlacement:[placementArray objectAtIndex:i]];
}

#pragma mark - Authentication

- (void)Authenticate:(nonnull NSString *)publisherHashID ApplicationHashID:(nonnull NSString *)applicationHashID
{
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	[ud setValue:publisherHashID    forKey:FLPUBLISHERHASHIDKEY];
    [ud setValue:applicationHashID  forKey:FLAPPLICATIONHASHIDKEY];
	[ud synchronize];
    
    if (_logEnable)
        [LogCenter NewLogTitle:@"Authentication" LogDescription:[NSString stringWithFormat:@"Credentials %@:%@ Are Recorded Successfuly", publisherHashID, applicationHashID] UserInfo:nil];
}

- (nullable NSMutableDictionary *)GetAuthenticationCredential
{
    NSMutableDictionary *dict   = [NSMutableDictionary      dictionary];
	NSUserDefaults *ud          = [NSUserDefaults           standardUserDefaults];
    [dict setValue:[ud valueForKey:FLPUBLISHERHASHIDKEY]    forKey:FLPUBLISHERHASHIDKEY];
    [dict setValue:[ud valueForKey:FLAPPLICATIONHASHIDKEY]  forKey:FLAPPLICATIONHASHIDKEY];
    
    if (_logEnable)
        [LogCenter NewLogTitle:@"Authentication" LogDescription:@"Retriving Recorded Credentials Successfuly" UserInfo:nil];
    
    return dict;
}

#pragma mark - Add Placement

- (void)AddPlacement:(nonnull NSString *)placementHashID
{
    for (int i = 0; i < [_placementHashIdArray count]; i++)
        if ([[_placementHashIdArray objectAtIndex:i] isEqualToString:placementHashID])
        {
            if (_logEnable)
                [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"Adding Placement %@ Failed Due to Duplication", placementHashID] UserInfo:nil];

            return;
        }
        
    [_placementHashIdArray addObject:placementHashID];

    FlieralPlacementManager *placementManager = [[FlieralPlacementManager alloc] initWithPlacementHashId:placementHashID];
    [_placementManagerArray addObject:placementManager];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:_placementHashIdArray forKey:FLPLACEMENTHASHIDKEY];
    [ud synchronize];
    
    if (_logEnable)
        [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"Placement %@ Added Successfully", placementHashID] UserInfo:nil];
}

- (NSMutableArray *)GetPlacements
{
    if (_logEnable)
        [LogCenter NewLogTitle:@"Placement Manager" LogDescription:@"Retriving Recorded Placements Successfuly" UserInfo:nil];

    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

    return [ud objectForKey:FLPLACEMENTHASHIDKEY];
}

#pragma mark - Start Flieral Engine

- (void)StartEngine
{
    internetReachabilityChecker = [Reachability reachabilityForInternetConnection];
    
    NetworkStatus status = [internetReachabilityChecker currentReachabilityStatus];
    [internetReachabilityChecker startNotifier];

    if (_logEnable)
        [LogCenter NewLogTitle:@"SDK Engine" LogDescription:@"Preparing Engine For Required Environemnts" UserInfo:nil];
    
    if (status != NotReachable)
    {
        if (![_userManager checkUserHashID])
        {
            [APIManager getUserHashIDWithSuccessBlock:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
                if (httpResponse.statusCode == 200)
                {
                    NSMutableDictionary *data = (NSMutableDictionary *)responseObject;
                    NSString *userhashId = [NSString stringWithString:[data valueForKey:@"response"]];

                    if (_logEnable)
                        [LogCenter NewLogTitle:@"SDK Engine" LogDescription:[NSString stringWithFormat:@"Getting User Unique Hash Identifier (%@) From Server Finished Successfuly", userhashId] UserInfo:nil];

                    [_userManager setUserHashID:userhashId];
                    _readyForStart = true;
                    [self ReadyForStart];
                }
            } failedBlock:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {

                if (_logEnable)
                    [LogCenter NewLogTitle:@"SDK Engine" LogDescription:@"Getting User Unique Hash Identifier From Server Failed (Engine Will Turn Off)" UserInfo:nil];

                _readyForStart = false;
            }];
        }
        else
        {
            if (_logEnable)
                [LogCenter NewLogTitle:@"SDK Engine" LogDescription:[NSString stringWithFormat:@"Using Recorded User Unique Hash Identifier (%@)", [_userManager getUserHashID]] UserInfo:nil];

            _readyForStart = true;
            [self ReadyForStart];
        }
    }
    else
    {
        if (_logEnable)
            [LogCenter NewLogTitle:@"SDK Engine" LogDescription:@"Connecting Engine to Server Failed (Starting Offline Mode)" UserInfo:nil];

        
        if ([_userManager checkForAuthenticationAndPlacementManager])
            _readyForWork = true;
    }
}

- (void)ReadyForStart
{
    if (_readyForStart)
    {
        if (_logEnable)
            [LogCenter NewLogTitle:@"SDK Engine" LogDescription:@"Preparing Engine For Ready to Start" UserInfo:nil];

        [APIManager sendAuthenticationToBackend:[self GetAuthenticationCredential] SuccessBlock:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
            if (httpResponse.statusCode == 200)
            {
                if (_logEnable)
                    [LogCenter NewLogTitle:@"SDK Engine" LogDescription:@"Sending Credentials to Server Finished Successfuly" UserInfo:nil];

                NSMutableDictionary *data = (NSMutableDictionary *)responseObject;
                NSArray *placementsInfoArray = (NSArray *)[data objectForKey:@"response"];
                for (int i = 0; i < [placementsInfoArray count]; i++)
                {
                    NSMutableDictionary *plModel        = (NSMutableDictionary *)[placementsInfoArray objectAtIndex:i];
                    FlieralPlacementManager *plManager  = [self GetPlacementWithHashID:[plModel valueForKey:@"id"]];
                    [plManager FillPlacementInstance:plModel];
                }
                    
                _readyForUse = true;
                [self ReadyForUse];
            }
        } failedBlock:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
            
            if (_logEnable)
                [LogCenter NewLogTitle:@"SDK Engine" LogDescription:@"Sending Credentials to Server Failed (Engine Will Turn Off)" UserInfo:nil];

            _readyForUse = false;
        }];
    }
}

- (void)ReadyForUse
{
    if (_readyForUse)
    {
        if (_logEnable)
            [LogCenter NewLogTitle:@"SDK Engine" LogDescription:@"Preparing Engine For Ready to Use" UserInfo:nil];

        _settingData        = [_userManager getUserSetting];
        _monitorData        = [_monitorManager getMonitorSetting];
        NSMutableDictionary *dict  = [NSMutableDictionary dictionary];
        [dict setValue:_settingData                 forKey:@"applicationModel"];
        [dict setValue:_monitorData                 forKey:@"pingModel"];
        [dict setValue:[_userManager getUserHashID] forKey:@"userId"];
        
        [APIManager sendUserInformation:dict SuccessBlock:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
            if (httpResponse.statusCode == 200)
            {
                if (_logEnable)
                    [LogCenter NewLogTitle:@"SDK Engine" LogDescription:@"Sending User Information to Server Finished Successfuly" UserInfo:nil];

                _readyForAlgorithm = true;
                [self StartAlgorithm];
            }
        } failedBlock:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {

            if (_logEnable)
                [LogCenter NewLogTitle:@"SDK Engine" LogDescription:@"Sending User Information to Server Failed (Engine Will Turn Off)" UserInfo:nil];

            _readyForAlgorithm = false;
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{

            if (_logEnable)
                [LogCenter NewLogTitle:@"SDK Engine" LogDescription:@"Preparing Sending Cache Contents to Server After 5 Seconds" UserInfo:nil];

            [[CacheManager sharedManager] sendCacheToBackend];
        });
    }
}

#pragma mark - Content Delivery Algorithm

- (void)StartAlgorithm
{
    NSMutableArray *lowArray        = [NSMutableArray array];
    NSMutableArray *averageArray    = [NSMutableArray array];
    NSMutableArray *highArray       = [NSMutableArray array];
    NSMutableIndexSet *indexSet     = [NSMutableIndexSet indexSet];
    
    if (_readyForAlgorithm)
    {
        if (_logEnable)
            [LogCenter NewLogTitle:@"SDK Engine" LogDescription:@"Preparing Engine For Starting Algorithms" UserInfo:nil];

        for (int i = 0; i < [_placementManagerArray count]; i++)
        {
            FlieralPlacementManager *plManager = [_placementManagerArray objectAtIndex:i];
            if ([plManager GetPlacementStatus] == Enable && [plManager CheckPlacementVisibility])
            {
                if ([plManager      GetPlacementPriority]   == HighPriority)
                    [highArray      addObject:plManager.instanceObject];
                else if ([plManager GetPlacementPriority]   == AveragePriority)
                    [averageArray   addObject:plManager.instanceObject];
                else if ([plManager GetPlacementPriority]   == LowPriority)
                    [lowArray       addObject:plManager.instanceObject];
            }
            else
                [indexSet addIndex:i];
        }
        
        [_placementHashIdArray  removeObjectsAtIndexes:indexSet];
        [_placementManagerArray removeObjectsAtIndexes:indexSet];

        if (_logEnable)
            [LogCenter NewLogTitle:@"SDK Engine" LogDescription:@"Running Algorithms For Engine Finished Successfuly" UserInfo:nil];

        [self SendContentRequest:highArray      AfterSeconds:0];
        [self SendContentRequest:averageArray   AfterSeconds:1];
        [self SendContentRequest:lowArray       AfterSeconds:2];
    }
}

- (void)SendContentRequest:(nullable NSArray *)placementsArray AfterSeconds:(int)time
{
    if (_logEnable)
        [LogCenter NewLogTitle:@"SDK Engine" LogDescription:[NSString stringWithFormat:@"Preparing Sending Content Request After %i Seconds", time] UserInfo:nil];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, time * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [APIManager sendRequestForContent:placementsArray userHashId:[_userManager getUserHashID] SuccessBlock:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
            if (httpResponse.statusCode == 200)
            {
                NSMutableDictionary *data   = (NSMutableDictionary *)responseObject;
                NSArray *responseArray      = (NSArray *) [data objectForKey:@"response"];
                for (int k = 0; k < [responseArray count]; k++)
                {
                    NSMutableDictionary *dict   = (NSMutableDictionary *) [responseArray objectAtIndex:k];
                    NSString *placementHashId   = [dict valueForKey:@"placementId"];
                    NSArray *onlineArray        = [dict objectForKey:@"onlineContent"];
                    NSArray *offlineArray       = [dict objectForKey:@"offlineContent"];
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
                }
                
                _readyForWork = true;
                
                [_userManager setAuthenticationAndPlacementManagerEnable];
                
                if (_logEnable)
                    [LogCenter NewLogTitle:@"SDK Engine" LogDescription:[NSString stringWithFormat:@"Sending Content Request After %i Seconds Finished Successfuly", time] UserInfo:nil];
            }
        } failedBlock:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {

            if (_logEnable)
                [LogCenter NewLogTitle:@"SDK Engine" LogDescription:[NSString stringWithFormat:@"Sending Content Request After %i Seconds Failed", time] UserInfo:nil];
        }];
    });
}

#pragma mark - Placement Manager

- (nullable FlieralPlacementManager *)GetPlacementWithHashID:(nonnull NSString *)placementHashID;
{
    for (int index = 0; index < [_placementHashIdArray count]; index++)
        if ([[_placementHashIdArray objectAtIndex:index] isEqualToString:placementHashID])
        {
            if (_logEnable)
                [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"Getting Placement (%@) Successfuly", placementHashID] UserInfo:nil];
            
            return [_placementManagerArray objectAtIndex:index];
        }

    if (_logEnable)
        [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"Getting Placement (%@) Failed", placementHashID] UserInfo:nil];

    return nil;
}

- (nullable FlieralPlacementManager *)GetPlacementFromIndex:(NSUInteger)index
{
    if (index <= (unsigned long)[_placementHashIdArray count])
    {
        if (_logEnable)
            [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"Getting Placement (%@) Successfuly", [_placementHashIdArray objectAtIndex:index]] UserInfo:nil];
        
        return [_placementManagerArray objectAtIndex:index];
    }
    
    if (_logEnable)
        [LogCenter NewLogTitle:@"Placement Manager" LogDescription:@"Getting Placement Failed" UserInfo:nil];
    
    return nil;
}

#pragma mark - User Delegate and Monitor Delegate

- (void)startMonitorAndSetting
{
    if (_logEnable)
        [LogCenter NewLogTitle:@"SDK Engine" LogDescription:@"Preparing Engine For Starting New Monnitor and Setting Checks" UserInfo:nil];

    _pingReady      = false;
    _userReady      = false;
    [_monitorManager    startPinging];
    [_userManager       startSetting];
}

- (void)monitorResponse:(nonnull NSMutableDictionary *)monitor
{
    if (_logEnable)
        [LogCenter NewLogTitle:@"Monitor Service" LogDescription:@"Getting Response From Monitor Service Delegate Successfuly" UserInfo:nil];

    _monitorData    = monitor;
    _pingReady      = true;
    [self sendNewInformation];
}

- (void)settingResponse:(nonnull NSMutableDictionary *)setting
{
    if (_logEnable)
        [LogCenter NewLogTitle:@"Setting Service" LogDescription:@"Getting Response From Monitor Service Delegate Successfuly" UserInfo:nil];

    _settingData    = setting;
    _userReady      = true;
    [self sendNewInformation];
}

- (void)sendNewInformation
{
    if (_pingReady && _userReady)
    {
        if (_logEnable)
            [LogCenter NewLogTitle:@"SDK Engine" LogDescription:@"Preparing Engine For Sending User New Information to Server" UserInfo:nil];
        
        _settingData        = [_userManager    getUserSetting];
        _monitorData        = [_monitorManager getMonitorSetting];
        NSMutableDictionary *dict  = [NSMutableDictionary dictionary];
        [dict setValue:_settingData                 forKey:@"applicationModel"];
        [dict setValue:_monitorData                 forKey:@"pingModel"];
        [dict setValue:[_userManager getUserHashID] forKey:@"userId"];
        
        [APIManager sendUserInformation:dict SuccessBlock:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
            if (httpResponse.statusCode == 200)
            {
                if (_logEnable)
                    [LogCenter NewLogTitle:@"SDK Engine" LogDescription:@"Sending User New Information to Server Finished Successfuly" UserInfo:nil];

                _pingReady = false;
                _userReady = false;
            }
        } failedBlock:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {

            if (_logEnable)
                [LogCenter NewLogTitle:@"SDK Engine" LogDescription:@"Sending User New Information to Server Failed" UserInfo:nil];
        }];
    }
}

@end
