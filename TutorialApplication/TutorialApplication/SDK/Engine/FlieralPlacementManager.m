//
//  FlieralPlacementManager.m
//  TutorialApplication
//
//  Created by Alireza Arabi on 9/17/16.
//  Copyright © 2016 Flieral Inc. All rights reserved.
//

#import "FlieralPlacementManager.h"
#import "FlieralSDKEngine.h"
#import "PlacementHelper.h"
#import "PlacementModel.h"
#import "PublicHeaders.h"
#import <WebKit/WebKit.h>
#import "Reachability.h"
#import "CacheManager.h"
#import "UserManager.h"
#import "APIManager.h"
#import "LogCenter.h"
#import "NSQueue.h"

@interface FlieralPlacementManager () <NSCoding, WKNavigationDelegate, WKScriptMessageHandler>
{
	Reachability *internetReachabilityChecker;
}

@property (nonatomic, strong) NSQueue * onlineQueue;
@property (nonatomic, strong) NSQueue * offlineQueue;

@property (nonatomic) PriorityType	placementPriority;
@property (nonatomic) StyleType		placementStyle;
@property (nonatomic) StatusType	placementStatus;

@property (nonatomic, copy, nullable) void (^preLoadBlock)(NSMutableDictionary         * _Nonnull details);
@property (nonatomic, copy, nullable) void (^didLoadBlock)(NSMutableDictionary         * _Nonnull details);
@property (nonatomic, copy, nullable) void (^failedLoadBlock)(NSMutableDictionary      * _Nonnull details);
@property (nonatomic, copy, nullable) void (^willAppearBlock)(NSMutableDictionary      * _Nonnull details);
@property (nonatomic, copy, nullable) void (^didAppearBlock)(NSMutableDictionary       * _Nonnull details);
@property (nonatomic, copy, nullable) void (^willDisappearBlock)(NSMutableDictionary   * _Nonnull details);
@property (nonatomic, copy, nullable) void (^didDisappearBlock)(NSMutableDictionary    * _Nonnull details);

@property (nonatomic, strong, nonnull) UIView * parentView;

@property (nonatomic, strong, nullable) UIVisualEffectView *blurEffectView;

@property (nonnull, strong) NSMutableArray * placementOnlineArray;
@property (nonnull, strong) NSMutableArray * placementOfflineArray;

@property (nonatomic, strong) WKWebView         * currentPlacementView;
@property (nonatomic, strong) PlacementModel    * currentPlacementModel;

@property (nonatomic, strong) FlieralSDKEngine  * SDKEngine;

@property (nonatomic) NSTimeInterval  beginningTime;
@property (nonatomic) NSTimeInterval  endingTime;

@end

@implementation FlieralPlacementManager

- (nullable id)initWithPlacementHashId:(nonnull NSString *)placementHashId
{
	self = [super init];
	if (self)
	{
		internetReachabilityChecker = [Reachability reachabilityForInternetConnection];
        
        _placementOnlineArray   = [NSMutableArray array];
        _placementOfflineArray  = [NSMutableArray array];
        _placementHashID = placementHashId;
        _placementStatus = Disable;
        
        _SDKEngine = [FlieralSDKEngine SDKEngine];
        
        if ([_SDKEngine LogEnable])
            [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"(%@) Creating New Placement Manager Pointer Successfuly", placementHashId] UserInfo:nil];
        
        if ([self loadPlacementManager:placementHashId])
        {
            if ([_SDKEngine LogEnable])
                [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"(%@) Loading Placement Manager Pointer Successfuly", placementHashId] UserInfo:nil];

            self = [self loadPlacementManager:placementHashId];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
	}
	return self;
}

#pragma mark - Fill Placement Instance

- (void)FillPlacementInstance:(nonnull NSMutableDictionary *)modelInstance
{
    if ([_SDKEngine LogEnable])
        [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"(%@) Filling Placement Manager Instance Successfuly", _placementHashID] UserInfo:nil];

    _onlineQueue    = [[NSQueue alloc] initWithIdentifier:_placementHashID Capacity:[[modelInstance valueForKey:@"onlineCapacity"]  intValue]];
    _offlineQueue   = [[NSQueue alloc] initWithIdentifier:_placementHashID Capacity:[[modelInstance valueForKey:@"offlineCapacity"] intValue]];

    [_onlineQueue   useAutomaticCachePolicyInOperations];
    [_offlineQueue  useAutomaticCachePolicyInOperations];

    NSString *styleInst = [modelInstance valueForKey:@"style"];
    if ([styleInst isEqualToString:@"Banner: Small"])
        _placementStyle = SmallBanner;
    else if ([styleInst isEqualToString:@"Banner: Medium"])
        _placementStyle = MediumBanner;
    else if ([styleInst isEqualToString:@"Banner: Large"])
        _placementStyle = LargeBanner;
    else if ([styleInst isEqualToString:@"Overlay"])
        _placementStyle = MediumInterstitial;
    else if ([styleInst isEqualToString:@"Interstitial"])
        _placementStyle = LargeInterstitial;

    NSString *priorityInst = [modelInstance valueForKey:@"priority"];
    if ([priorityInst isEqualToString:@"Low"])
        _placementPriority = LowPriority;
    else if ([priorityInst isEqualToString:@"Average"])
        _placementPriority = AveragePriority;
    else if ([priorityInst isEqualToString:@"High"])
        _placementPriority = HighPriority;
    
    NSString *statusInst = [modelInstance valueForKey:@"status"];
    if ([statusInst isEqualToString:@"Enable"])
        _placementStatus = Enable;
    else if ([statusInst isEqualToString:@"Disable"])
        _placementStatus = Disable;

    _beginningTime  = [[modelInstance valueForKey:@"beginningTime"] doubleValue];
    _endingTime     = [[modelInstance valueForKey:@"endingTime"]    doubleValue];
    
    _instanceObject = modelInstance;
    
    [self savePlacementManager];
}

- (PriorityType)GetPlacementPriority
{
    return _placementPriority;
}

- (StatusType)GetPlacementStatus
{
    return _placementStatus;
}

- (BOOL)CheckPlacementVisibility
{
    NSTimeInterval now = ([[NSDate date] timeIntervalSince1970] * 1000);
    if (now >= _beginningTime && now <= _endingTime)
        return true;
    return false;
}

- (void)AddPlacementOnlineContent:(nonnull PlacementModel *)modelInstance
{
    if ([_SDKEngine LogEnable])
        [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"(%@) Adding Placement Model To Online Array Successfuly", _placementHashID] UserInfo:nil];

    [_placementOnlineArray addObject:modelInstance];
    [self RequestForFile:modelInstance isOnline:YES];
}

- (void)AddPlacementOfflineContent:(nonnull PlacementModel *)modelInstance
{
    if ([_SDKEngine LogEnable])
        [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"(%@) Adding Placement Model To Offline Array Successfuly", _placementHashID] UserInfo:nil];

    [_placementOfflineArray addObject:modelInstance];
    [self RequestForFile:modelInstance isOnline:NO];
}

- (void)RequestForFile:(nonnull PlacementModel *)modelInstance isOnline:(BOOL)isOnline
{
    [self EventListener:PreLoad Details:nil];
    
    NSString *fileName = [NSString stringWithFormat:@"%@.html", modelInstance.subcampaignHashID];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:modelInstance.campaignHashID     forKey:@"campaignHashId"];
    [dict setValue:modelInstance.subcampaignHashID  forKey:@"subcampaignHashId"];
    
    NSURL *documentsDirectoryURL    = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    NSURL *destinationURL           = [documentsDirectoryURL URLByAppendingPathComponent:fileName];
    
    if (![[PlacementHelper sharedHelper] checkForFileExistsAtPath:[destinationURL path]])
    {
        [APIManager downloadContentWithInformation:dict Path:destinationURL SuccessBlock:^(NSURLResponse * _Nonnull response, NSURL * _Nonnull filePath) {
            [modelInstance setContentURL:filePath];
            
            if (isOnline)
            {
                if ([_SDKEngine LogEnable])
                    [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"(%@) Downloading Content To Online Queue Finished Successfuly", _placementHashID] UserInfo:nil];

                [_onlineQueue   enqueue:modelInstance];
                [self EventListener:DidLoad Details:nil];
            }
            else
            {
                if ([_SDKEngine LogEnable])
                    [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"(%@) Downloading Content To Offline Queue Finished Successfuly", _placementHashID] UserInfo:nil];

                [_offlineQueue  enqueue:modelInstance];
                [self EventListener:DidLoad Details:nil];
            }
            
            [[PlacementHelper sharedHelper] saveTimerForContent:modelInstance.subcampaignHashID];
            [self savePlacementManager];
            
        } failedBlock:^(NSError * _Nonnull error) {

            if ([_SDKEngine LogEnable])
                [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"(%@) Downloading Content To Offline Queue Failed Successfuly", _placementHashID] UserInfo:nil];

            [self EventListener:FailedLoad Details:nil];
        }];
    }
    else
    {
        [self EventListener:DidLoad Details:nil];
        
        [[PlacementHelper sharedHelper] saveTimerForContent:modelInstance.subcampaignHashID];
        [self savePlacementManager];
    }
}

#pragma mark - Block Event Action Listener

- (void)SetPreLoadBlock:(nullable void (^)(NSMutableDictionary * _Nonnull details)) preLoadBlock
{
    _preLoadBlock = preLoadBlock;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preLoadBlock)         name:FLPRELOADVIEW          object:nil];

    if ([_SDKEngine LogEnable])
        [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"(%@) Adding PreLoad Listener To Placement Successfuly", _placementHashID] UserInfo:nil];
}

- (void)SetDidLoadBlock:(nullable void (^)(NSMutableDictionary * _Nonnull details)) didLoadBlock
{
    _didLoadBlock = didLoadBlock;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoadBlock)         name:FLDIDLOADVIEW          object:nil];

    if ([_SDKEngine LogEnable])
        [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"(%@) Adding DidLoad Listener To Placement Successfuly", _placementHashID] UserInfo:nil];
}

- (void)SetFailedLoadBlock:(nullable void (^)(NSMutableDictionary * _Nonnull details)) failedLoadBlock
{
    _failedLoadBlock = failedLoadBlock;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failedLoadBlock)      name:FLFAILEDLOADVIEW       object:nil];
    
    if ([_SDKEngine LogEnable])
        [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"(%@) Adding FailedLoad Listener To Placement Successfuly", _placementHashID] UserInfo:nil];
}

- (void)SetWillAppearBlock:(nullable void (^)(NSMutableDictionary * _Nonnull details)) willAppearBlock
{
    _willAppearBlock = willAppearBlock;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willAppearBlock)      name:FLWILLAPPEARVIEW       object:nil];
    
    if ([_SDKEngine LogEnable])
        [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"(%@) Adding WillAppear Listener To Placement Successfuly", _placementHashID] UserInfo:nil];
}

- (void)SetDidAppearBlock:(nullable void (^)(NSMutableDictionary * _Nonnull details)) didAppearBlock
{
    _didAppearBlock = didAppearBlock;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAppearBlock)       name:FLDIDAPPEARVIEW        object:nil];
    
    if ([_SDKEngine LogEnable])
        [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"(%@) Adding DidAppear Listener To Placement Successfuly", _placementHashID] UserInfo:nil];
}

- (void)SetWillDisappearBlock:(nullable void (^)(NSMutableDictionary * _Nonnull details)) willDisappearBlock
{
    _willDisappearBlock = willDisappearBlock;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willDisappearBlock)   name:FLWILLDISAPPEARVIEW    object:nil];
    
    if ([_SDKEngine LogEnable])
        [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"(%@) Adding WillDisappear Listener To Placement Successfuly", _placementHashID] UserInfo:nil];
}

- (void)SetDidDisappearBlock:(nullable void (^)(NSMutableDictionary * _Nonnull details)) didDisappearBlock
{
    _didDisappearBlock = didDisappearBlock;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDisappearBlock)    name:FLDIDDISAPPEARVIEW     object:nil];
    
    if ([_SDKEngine LogEnable])
        [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"(%@) Adding DidDisappear Listener To Placement Successfuly", _placementHashID] UserInfo:nil];
}

- (void)EventListener:(Event)eventAction Details:(nullable NSMutableDictionary *) details
{
    if ([_SDKEngine LogEnable])
        [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"(%@) Preapring For Firing Block Event %ld", _placementHashID, (long)eventAction] UserInfo:nil];

    if (!details)
        [details setValue:@"Successful" forKey:@"Status"];
    
    switch (eventAction)
    {
        case PreLoad:
            if (_preLoadBlock)
                _preLoadBlock(details);
            break;
            
        case DidLoad:
            if (_didLoadBlock)
                _didLoadBlock(details);
            break;
            
        case FailedLoad:
            if (_failedLoadBlock)
                _failedLoadBlock(details);
            break;
            
        case WillAppear:
            if (_willAppearBlock)
                _willAppearBlock(details);
            break;
            
        case DidAppear:
            if (_didAppearBlock)
                _didAppearBlock(details);
            break;
            
        case WillDisappear:
            if (_willDisappearBlock)
                _willDisappearBlock(details);
            break;
            
        case DidDisappear:
            if (_didDisappearBlock)
                _didDisappearBlock(details);
            break;
            
        default:
            break;
    }
    
    if ([_SDKEngine LogEnable])
        [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"(%@) Listener %ld Fired Successfuly", _placementHashID, (long)eventAction] UserInfo:nil];
}

- (void)saveCache:(nonnull NSDictionary *)data
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:data];
    [[CacheManager sharedManager] addNewCacheModel:dict];
    
    if ([_SDKEngine LogEnable])
        [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"(%@) New Cache Data Saved Successfuly", _placementHashID] UserInfo:nil];
}

#pragma mark - Main Actions

- (void)Hide
{
	if (!_parentView || _placementStatus != Enable || !_currentPlacementModel || !_currentPlacementView)
		return;
	
    [self EventListener:WillDisappear Details:nil];
    
	[self hideWebView];
}

- (void)Show
{
	if (!_parentView || _placementStatus != Enable)
		return;
    
	if ([internetReachabilityChecker isReachable] && [_onlineQueue checkFillQueue])
		[self showOnlineContent];
	else if (![internetReachabilityChecker isReachable] && [_offlineQueue checkFillQueue])
		[self showOfflineContent];
}

#pragma mark - Parent View Setting

- (void)SetParentView:(nonnull UIView *)view
{
    _parentView = view;
    
    if ([_SDKEngine LogEnable])
        [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"(%@) Parent View Has Been Set Successfuly", _placementHashID] UserInfo:nil];
}

- (void)SetParentViewController:(nonnull UIViewController *)viewController
{
    _parentView = viewController.view;
    
    if ([_SDKEngine LogEnable])
        [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"(%@) Parent View Has Been Set Successfuly", _placementHashID] UserInfo:nil];
}

- (nullable UIView *)getParentView
{
    return _parentView;
}

#pragma mark - Shoe/Hide/Remove Actions

- (void)showOnlineContent;
{
    if ([_SDKEngine LogEnable])
        [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"(%@) Preparing For Online Content Show", _placementHashID] UserInfo:nil];

    WKWebViewConfiguration *theConfiguration = [[WKWebViewConfiguration alloc] init];
    [theConfiguration.userContentController addScriptMessageHandler:self name:@"FlieralSDK"];

    WKWebView *placementContent = [[WKWebView alloc] initWithFrame:[self frameForType] configuration:theConfiguration];
    placementContent.navigationDelegate = self;
    PlacementModel *model       = (PlacementModel *)[_onlineQueue dequeue];

    [placementContent loadFileURL:model.contentURL allowingReadAccessToURL:model.contentURL];

    [self showWebView:placementContent PlacementModel:model];

    if ([_SDKEngine LogEnable])
        [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"(%@) Online Content Show Prepared Successfuly", _placementHashID] UserInfo:nil];
}

- (void)showOfflineContent
{
    if ([_SDKEngine LogEnable])
        [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"(%@) Preparing For Offline Content Show", _placementHashID] UserInfo:nil];

    WKWebViewConfiguration *theConfiguration = [[WKWebViewConfiguration alloc] init];
    [theConfiguration.userContentController addScriptMessageHandler:self name:@"FlieralSDK"];
    
    WKWebView *placementContent = [[WKWebView alloc] initWithFrame:[self frameForType] configuration:theConfiguration];
    placementContent.navigationDelegate = self;
    PlacementModel *model       = (PlacementModel *)[_offlineQueue dequeue];
    
    [placementContent loadFileURL:model.contentURL allowingReadAccessToURL:model.contentURL];
    
    [self showWebView:placementContent PlacementModel:model];
    
    if ([_SDKEngine LogEnable])
        [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"(%@) Offline Content Show Prepared Successfuly", _placementHashID] UserInfo:nil];
}

- (void)showWebView:(WKWebView *)webView PlacementModel:(PlacementModel *)model
{
    if ([_SDKEngine LogEnable])
        [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"(%@) Preparing For Adding Placement To Superview", _placementHashID] UserInfo:nil];

    NSUserDefaults *ud      = [NSUserDefaults standardUserDefaults];
    NSString *timerKey      = [FLSTORAGETIMERKEY stringByAppendingString:model.placementHashID];
    NSString *hiddenKey     = [FLSTORAGEHIDDENKEY stringByAppendingString:model.placementHashID];
    
    [self EventListener:WillAppear Details:nil];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    if ([ud boolForKey:hiddenKey])
    {
        if ([ud integerForKey:timerKey] > [[NSDate date] timeIntervalSince1970])
        {
            _currentPlacementModel  = model;
            _currentPlacementView   = webView;
            
            [webView        setHidden:false];
            [_parentView    addSubview:webView];
            
            [ud setBool:false forKey:hiddenKey];
            [ud synchronize];
            
            if ([_SDKEngine LogEnable])
                [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"(%@) Placement Unhidded In Superview Successfully", _placementHashID] UserInfo:nil];
        }
    }
    else
    {
        _currentPlacementModel  = model;
        _currentPlacementView   = webView;
        
        [_parentView addSubview:webView];
        [self fetchNextContents];
        
        if ([_SDKEngine LogEnable])
            [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"(%@) Placement Added To Superview Successfuly", _placementHashID] UserInfo:nil];
    }
    
    NSMutableDictionary *actionDict     = [NSMutableDictionary dictionary];
    NSString *time = [NSString stringWithFormat:@"%li", (long)([[NSDate date] timeIntervalSince1970] * 1000)];
    [actionDict     setObject:time          forKey:@"time"];
    [actionDict     setObject:@"View"       forKey:@"event"];

    [self sendEventData:actionDict AnnouncerData:[_currentPlacementModel getAnnouncerModel] PublisherData:[_currentPlacementModel getPublisherModel]];
    
    [self EventListener:DidAppear Details:nil];
}

- (void)hideWebView
{
    if ([_SDKEngine LogEnable])
        [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"(%@) Preparing For Hidding Placement From Superview", _placementHashID] UserInfo:nil];

    NSUserDefaults *ud  = [NSUserDefaults       standardUserDefaults];
    NSString *timerKey  = [FLSTORAGETIMERKEY    stringByAppendingString:_currentPlacementModel.placementHashID];
    NSString *hiddenKey = [FLSTORAGEHIDDENKEY   stringByAppendingString:_currentPlacementModel.placementHashID];
    
    if (![ud boolForKey:hiddenKey])
    {
        int val = [[NSDate date] timeIntervalSince1970] + FLDEFAULTTIMER;
        [ud setInteger:val  forKey:timerKey];
        [ud setBool:true    forKey:hiddenKey];
        [ud synchronize];
        
        [_currentPlacementView setHidden:true];
        
        if ([_SDKEngine LogEnable])
            [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"(%@) Placement Hidded From Superview Successfuly", _placementHashID] UserInfo:nil];

        [self EventListener:DidDisappear Details:nil];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, FLDEFAULTTIMER * NSEC_PER_SEC), dispatch_get_main_queue(), ^{

            if ([_SDKEngine LogEnable])
                [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"(%@) Hidden Threshold Timer Reached Successfuly", _placementHashID] UserInfo:nil];
            
            if ([ud boolForKey:hiddenKey])
            {
                if ([_SDKEngine LogEnable])
                    [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"(%@) Placement Didn't Become Shown After Hiding", _placementHashID] UserInfo:nil];

                NSMutableDictionary *innerDict = [NSMutableDictionary dictionary];
                [innerDict setValue:@"Report" forKey:@"event"];
                [innerDict setValue:[NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970] * 1000.0] forKey:@"time"];
                
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [dict setObject:[UserManager getUserPublicSetting]          forKey:@"userInfo"];
                [dict setObject:[_currentPlacementModel getAnnouncerModel]  forKey:@"announcerInfo"];
                [dict setObject:[_currentPlacementModel getPublisherModel]  forKey:@"publisherInfo"];
                [dict setObject:innerDict                                   forKey:@"actionInfo"];
                
                [APIManager sendReportToBackend:dict SuccessBlock:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
                    if (httpResponse.statusCode == 200)
                    {
                        if ([_SDKEngine LogEnable])
                            [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"(%@) Sending Hidden Threshold Timer Report Finished Successfuly", _placementHashID] UserInfo:nil];
                    }
                } failedBlock:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {

                    if ([_SDKEngine LogEnable])
                        [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"(%@) Sending Hidden Threshold Timer Report Failed", _placementHashID] UserInfo:nil];
                }];
            }
        });
    }
}

- (void)removePlacement
{
    [self EventListener:WillDisappear Details:nil];
    
    if (!_parentView || _placementStatus != Enable || !_currentPlacementModel || !_currentPlacementView)
        return;
    
    [_currentPlacementView  removeFromSuperview];
    _currentPlacementView   = nil;
    _currentPlacementModel  = nil;
    
    if (_blurEffectView)
    {
        [_blurEffectView    removeFromSuperview];
        _blurEffectView     = nil;
    }
    
    [self EventListener:DidDisappear Details:nil];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    if ([_SDKEngine LogEnable])
        [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"(%@) Placement Removed From Superview Successfuly", _placementHashID] UserInfo:nil];
}

#pragma mark - Frame and Size Calculator

- (CGRect)frameForType
{
    CGPoint edge    = _parentView.frame.origin;
    double width    = _parentView.frame.size.width;
    double height   = _parentView.frame.size.height;

    switch (_placementStyle)
    {
        case SmallBanner:
            return CGRectMake(0, height - (0.15 * height), width, (0.15 * height));
            break;
        case MediumBanner:
            return CGRectMake(0, height - (0.2 * height), width, (0.2 * height));
            break;
        case LargeBanner:
            return CGRectMake(0, height - (0.25 * height), width, (0.25 * height));
            break;
        case MediumInterstitial:
            if (!UIAccessibilityIsReduceTransparencyEnabled()) {
                _parentView.backgroundColor = [UIColor clearColor];
                
                UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
                UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
                blurEffectView.frame = _parentView.bounds;
                blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                
                _blurEffectView = blurEffectView;
                
                [_parentView addSubview:blurEffectView];
            } else {
                _parentView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
            }
            return CGRectMake((width - (0.85 * width)) / 2, (height - (0.9 * height)) / 2, (0.85 * width), (0.9 * height));
            break;
        case LargeInterstitial:
            return CGRectMake(edge.x, edge.y, width, height);
            break;
        default:
            break;
    }
    return CGRectMake(0, 0, 0, 0);
}

- (void)setConstraint
{
    [_currentPlacementView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSLayoutConstraint *left    = [NSLayoutConstraint constraintWithItem:_currentPlacementView attribute:NSLayoutAttributeLeft      relatedBy:NSLayoutRelationEqual toItem:_parentView attribute:NSLayoutAttributeLeft      multiplier:1 constant:(_currentPlacementView.frame.origin.x)];
    NSLayoutConstraint *top     = [NSLayoutConstraint constraintWithItem:_currentPlacementView attribute:NSLayoutAttributeTop       relatedBy:NSLayoutRelationEqual toItem:_parentView attribute:NSLayoutAttributeTop       multiplier:1 constant:(_currentPlacementView.frame.origin.y)];
    NSLayoutConstraint *right   = [NSLayoutConstraint constraintWithItem:_currentPlacementView attribute:NSLayoutAttributeRight     relatedBy:NSLayoutRelationEqual toItem:_parentView attribute:NSLayoutAttributeRight     multiplier:1 constant:(_currentPlacementView.frame.origin.x)];
    NSLayoutConstraint *bottom  = [NSLayoutConstraint constraintWithItem:_currentPlacementView attribute:NSLayoutAttributeBottom    relatedBy:NSLayoutRelationEqual toItem:_parentView attribute:NSLayoutAttributeBottom    multiplier:1 constant:(_currentPlacementView.frame.origin.y)];
    
    [_parentView addConstraints:@[left, right, top, bottom]];
}

- (void)orientationChanged:(NSNotification *)notification
{
    if (_currentPlacementView)
    {
        [_currentPlacementView setFrame:[self frameForType]];
        [self setConstraint];
    }
}

#pragma mark - Fetch Next Operations

- (void)fetchNextContents
{
    if ([_SDKEngine LogEnable])
        [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"(%@) Preparing For New Content Fetch", _placementHashID] UserInfo:nil];

    if ([internetReachabilityChecker isReachable])
        if ([_onlineQueue checkForEmptySpace] || [_offlineQueue checkForEmptySpace])
            [[FlieralSDKEngine SDKEngine] SendContentRequest:@[_placementHashID] AfterSeconds:0];
}

#pragma mark - Storage and Coding Delegates

- (void)savePlacementManager
{
    if ([_SDKEngine LogEnable])
        [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"(%@) Preparing For Placement Manager Save", _placementHashID] UserInfo:nil];

    NSString *key           = [NSString         stringWithFormat:@"%@:%@", FLPLACEMENTMANAGERSTORAGE, _placementHashID];
    NSUserDefaults *ud      = [NSUserDefaults   standardUserDefaults];
    NSData *encodedObject   = [NSKeyedArchiver  archivedDataWithRootObject:self];
    
    [ud setObject:encodedObject forKey:key];
    [ud synchronize];

    if ([_SDKEngine LogEnable])
        [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"(%@) Placement Manager Saved Successfuly", _placementHashID] UserInfo:nil];
}

- (nullable FlieralPlacementManager *)loadPlacementManager:(nonnull NSString *)placementHashId
{
    if ([_SDKEngine LogEnable])
        [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"(%@) Preparing For Placement Manager Load", _placementHashID] UserInfo:nil];

    NSString *key           = [NSString         stringWithFormat:@"%@:%@", FLPLACEMENTMANAGERSTORAGE, placementHashId];
    NSUserDefaults *ud      = [NSUserDefaults   standardUserDefaults];
    NSData *encodedObject   = [ud               objectForKey:key];

    if ([_SDKEngine LogEnable])
        [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"(%@) Placement Manager Loaded Successfuly", _placementHashID] UserInfo:nil];

    if (encodedObject)
        return (FlieralPlacementManager *)[NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    
    return nil;
}

- (void)loadQueuesForPlacementManager:(nonnull NSString *)placementHashId
{
    if ([_SDKEngine LogEnable])
        [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"(%@) Preparing For Placement Manager Queues Load", _placementHashID] UserInfo:nil];

    [_onlineQueue   loadQueueContentForPlacementIdentifier:placementHashId];
    [_offlineQueue  loadQueueContentForPlacementIdentifier:placementHashId];

    [_onlineQueue   useAutomaticCachePolicyInOperations];
    [_offlineQueue  useAutomaticCachePolicyInOperations];
    
    if ([_SDKEngine LogEnable])
        [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"(%@) Placement Manager Queues Loaded Successfuly", _placementHashID] UserInfo:nil];
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.placementHashID          forKey:@"PLACEMENTHASHID"];
    [encoder encodeObject:self.instanceObject           forKey:@"INSTANCEOBJECT"];
    [encoder encodeObject:self.onlineQueue              forKey:@"ONLINEQUEUE"];
    [encoder encodeObject:self.offlineQueue             forKey:@"OFFLINEQUQUE"];
    [encoder encodeInt:self.placementPriority           forKey:@"PLACEMENTPRIORITY"];
    [encoder encodeInt:self.placementStyle              forKey:@"PLACEMENTSTYLE"];
    [encoder encodeInt:self.placementStatus             forKey:@"PLACEMENTSTATUS"];
    [encoder encodeObject:self.placementOnlineArray     forKey:@"PLACEMENTONLINEARRAY"];
    [encoder encodeObject:self.placementOfflineArray    forKey:@"PLACEMENTOFFLINEARRAY"];
    [encoder encodeObject:self.currentPlacementView     forKey:@"CURRENTPLACEMENTVIEW"];
    [encoder encodeObject:self.currentPlacementModel    forKey:@"CURRENTPLACEMENTMODEL"];
    [encoder encodeDouble:self.beginningTime            forKey:@"BEGINNINGTIME"];
    [encoder encodeDouble:self.endingTime               forKey:@"ENDINGTIME"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if(self)
    {
        self.placementHashID        = [decoder decodeObjectForKey:@"PLACEMENTHASHID"];
        self.instanceObject         = [decoder decodeObjectForKey:@"INSTANCEOBJECT"];
        self.onlineQueue            = [decoder decodeObjectForKey:@"ONLINEQUEUE"];
        self.offlineQueue           = [decoder decodeObjectForKey:@"OFFLINEQUQUE"];
        self.placementPriority      = [decoder decodeIntForKey:@"PLACEMENTPRIORITY"];
        self.placementStyle         = [decoder decodeIntForKey:@"PLACEMENTSTYLE"];
        self.placementStatus        = [decoder decodeIntForKey:@"PLACEMENTSTATUS"];
        self.placementOnlineArray   = [decoder decodeObjectForKey:@"PLACEMENTONLINEARRAY"];
        self.placementOfflineArray  = [decoder decodeObjectForKey:@"PLACEMENTOFFLINEARRAY"];
        self.currentPlacementView   = [decoder decodeObjectForKey:@"CURRENTPLACEMENTVIEW"];
        self.currentPlacementModel  = [decoder decodeObjectForKey:@"CURRENTPLACEMENTMODEL"];
        self.beginningTime          = [decoder decodeDoubleForKey:@"BEGINNINGTIME"];
        self.endingTime             = [decoder decodeDoubleForKey:@"ENDINGTIME"];
    }
    return self;
}

#pragma mark - UI Web View Delegate

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSDictionary *sentData      = (NSDictionary *)message.body;
    NSString *actionType        = [sentData objectForKey:@"function"];
    
    NSString *saveAction    = @"saveCache";
    NSString *removeAction  = @"removePlacement";
    NSString *clickAction   = @"clickedPlacement";

    if ([actionType isEqualToString:saveAction])
    {
        NSDictionary *jsonDictString    = [sentData objectForKey:@"input"];
        [self saveCache:jsonDictString];
    }
    
    if ([actionType isEqualToString:removeAction])
        [self removePlacement];
    
    if ([actionType isEqualToString:clickAction])
    {
        [self removePlacement];

        NSDictionary *jsonDictString    = [sentData objectForKey:@"input"];
        NSDictionary *dict = jsonDictString;
        
        NSMutableDictionary *announcerDict  = [NSMutableDictionary dictionary];
        [announcerDict  setObject:[dict objectForKey:@"announcerHashId"]     forKey:@"announcerHashId"];
        [announcerDict  setObject:[dict objectForKey:@"campaignHashId"]      forKey:@"campaignHashId"];
        [announcerDict  setObject:[dict objectForKey:@"subcampaignHashId"]   forKey:@"subcampaignHashId"];
        
        NSMutableDictionary *publisherDict  = [NSMutableDictionary dictionary];
        [publisherDict  setObject:[dict objectForKey:@"publisherHashId"]     forKey:@"publisherHashId"];
        [publisherDict  setObject:[dict objectForKey:@"applicationHashId"]   forKey:@"applicationHashId"];
        [publisherDict  setObject:[dict objectForKey:@"placementHashId"]     forKey:@"placementHashId"];
        
        NSMutableDictionary *actionDict     = [NSMutableDictionary dictionary];
        [actionDict     setObject:[dict objectForKey:@"time"]       forKey:@"time"];
        [actionDict     setObject:@"Click"                          forKey:@"event"];
        
        [self sendEventData:actionDict AnnouncerData:announcerDict PublisherData:publisherDict];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    NSString *jsFunction = [NSString stringWithFormat:@"setInfo(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\");", [UserManager getUserHashID], _currentPlacementModel.subcampaignHashID, _currentPlacementModel.campaignHashID, _currentPlacementModel.announcerHashID, _currentPlacementModel.placementHashID, _currentPlacementModel.applicationHashID, _currentPlacementModel.publisherHashID];

    [_currentPlacementView evaluateJavaScript:jsFunction completionHandler:^(NSString * _Nullable result, NSError * _Nullable error) {
        if (error)
        {
            NSLog(@"%@", error);
            if ([_SDKEngine LogEnable])
                [LogCenter NewLogTitle:@"Placement Manager" LogDescription:[NSString stringWithFormat:@"(%@) Placement Evaluating JavaScript Function Failed", _placementHashID] UserInfo:nil];
        }
    }];
}

#pragma mark - Statistics Operations

- (void)sendEventData:(nonnull NSMutableDictionary *)actionData AnnouncerData:(nonnull NSMutableDictionary *)announcerData PublisherData:(nonnull NSMutableDictionary *)publisherData
{
    if ([_SDKEngine LogEnable])
        [LogCenter NewLogTitle:@"Placement Manager" LogDescription:@"Preparing Environement For Sending Stats to Backend" UserInfo:nil];

    NSMutableDictionary *innerDict = [NSMutableDictionary dictionary];
    [innerDict setValue:@"Report" forKey:@"event"];
    [innerDict setValue:[NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970] * 1000.0] forKey:@"time"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[UserManager getUserPublicSetting]          forKey:@"userInfo"];
    [dict setObject:announcerData  forKey:@"announcerInfo"];
    [dict setObject:publisherData  forKey:@"publisherInfo"];
    [dict setObject:actionData     forKey:@"actionInfo"];
    
    [APIManager sendReportToBackend:dict SuccessBlock:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if (httpResponse.statusCode == 200)
        {
            if ([_SDKEngine LogEnable])
                [LogCenter NewLogTitle:@"Placement Manager" LogDescription:@"Sending Stats Data to Backend Finished Successfuly" UserInfo:nil];
        }
    } failedBlock:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        
        if ([_SDKEngine LogEnable])
            [LogCenter NewLogTitle:@"Placement Manager" LogDescription:@"Sending Stats Data to Backend Failed" UserInfo:nil];
    }];
}

@end
