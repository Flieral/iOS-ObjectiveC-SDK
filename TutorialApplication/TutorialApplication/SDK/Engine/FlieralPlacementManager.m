//
//  FlieralPlacementManager.m
//  TutorialApplication
//
//  Created by Alireza Arabi on 9/17/16.
//  Copyright © 2016 Flieral Inc. All rights reserved.
//

#import "FlieralPlacementManager.h"
#import "PlacementModel.h"
#import "PublicHeaders.h"
#import "Reachability.h"
#import "CacheManager.h"
#import "APIManager.h"
#import "NSQueue.h"

@interface FlieralPlacementManager () <NSCoding>
{
	Reachability *internetReachabilityChecker;
}

@property (nonatomic, strong) NSQueue * onlineQueue;
@property (nonatomic, strong) NSQueue * offlineQueue;

@property (nonatomic) PriorityType	placementPriority;
@property (nonatomic) StyleType		placementStyle;
@property (nonatomic) StatusType	placementStatus;

@property (nonatomic, copy, nullable) void (^preLoadBlock)(NSDictionary         * _Nonnull details);
@property (nonatomic, copy, nullable) void (^didLoadBlock)(NSDictionary         * _Nonnull details);
@property (nonatomic, copy, nullable) void (^failedLoadBlock)(NSDictionary      * _Nonnull details);
@property (nonatomic, copy, nullable) void (^willAppearBlock)(NSDictionary      * _Nonnull details);
@property (nonatomic, copy, nullable) void (^didAppearBlock)(NSDictionary       * _Nonnull details);
@property (nonatomic, copy, nullable) void (^willDisappearBlock)(NSDictionary   * _Nonnull details);
@property (nonatomic, copy, nullable) void (^didDisappearBlock)(NSDictionary    * _Nonnull details);

@property (nonatomic, strong, nonnull) UIView * parentView;

@property (nonnull, strong) NSMutableArray *placementOnlineArray;
@property (nonnull, strong) NSMutableArray *placementOfflineArray;

@end

@implementation FlieralPlacementManager

- (nullable id)initWithPlacementHashId:(nonnull NSString *)placementHashId
{
	self = [super init];
	if (self)
	{
		internetReachabilityChecker = [Reachability reachabilityForInternetConnection];
        _placementOnlineArray = [NSMutableArray array];
        _placementOfflineArray = [NSMutableArray array];
        _placementHashID = placementHashId;
        _placementStatus = Disable;
	}
	return self;
}

#pragma mark - Fill Placement Instance

- (void)FillPlacementInstance:(nonnull NSDictionary *)modelInstance
{
    _onlineQueue = [[NSQueue alloc] initWithIdentifier:_placementHashID Capacity:[[modelInstance valueForKey:@"onlineCapacity"] intValue]];
    _offlineQueue = [[NSQueue alloc] initWithIdentifier:_placementHashID Capacity:[[modelInstance valueForKey:@"offlineCapacity"] intValue]];

    [_onlineQueue useAutomaticCachePolicyInOperations];
    [_offlineQueue useAutomaticCachePolicyInOperations];

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
    
    _instanceObject = modelInstance;
}

- (PriorityType)GetPlacementPriority
{
    return _placementPriority;
}

- (StatusType)GetPlacementStatus
{
    return _placementStatus;
}

- (void)AddPlacementOnlineContent:(nonnull PlacementModel *)modelInstance
{
    [_placementOnlineArray addObject:modelInstance];
    [self RequestForFile:modelInstance isOnline:YES];
}

- (void)AddPlacementOfflineContent:(nonnull PlacementModel *)modelInstance
{
    [_placementOfflineArray addObject:modelInstance];
    [self RequestForFile:modelInstance isOnline:NO];
}

- (void)RequestForFile:(nonnull PlacementModel *)modelInstance isOnline:(BOOL)isOnline
{
    NSString *fileName = modelInstance.subcampaignHashID;
    
    NSDictionary *dict = [NSDictionary dictionary];
    [dict setValue:modelInstance.campaignHashID forKey:@"campaignHashId"];
    [dict setValue:modelInstance.subcampaignHashID forKey:@"subcampaignHashId"];
    
    NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    NSURL *destURL = [documentsDirectoryURL URLByAppendingPathComponent:fileName];

    // check for existance
    // if not send req
    
    [APIManager downloadContentWithInformation:dict Path:destURL SuccessBlock:^(NSURLResponse * _Nonnull response, NSURL * _Nonnull filePath) {
        
        [modelInstance setContentURL:filePath];
       
        if (isOnline)
        {
            
        }
        else
        {
            
        }
        
    } failedBlock:^(NSError * _Nonnull error) {
        //
    }];
}

#pragma mark - Block Event Action Listener

- (void)SetPreLoadBlock:(nullable void (^)(NSDictionary * _Nonnull details)) preLoadBlock
{
    _preLoadBlock = preLoadBlock;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preLoadBlock) name:FLPRELOADVIEW object:nil];
}

- (void)SetDidLoadBlock:(nullable void (^)(NSDictionary * _Nonnull details)) didLoadBlock
{
    _didLoadBlock = didLoadBlock;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoadBlock) name:FLDIDLOADVIEW object:nil];
}

- (void)SetFailedLoadBlock:(nullable void (^)(NSDictionary * _Nonnull details)) failedLoadBlock
{
    _failedLoadBlock = failedLoadBlock;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failedLoadBlock) name:FLFAILEDLOADVIEW object:nil];
}

- (void)SetWillAppearBlock:(nullable void (^)(NSDictionary * _Nonnull details)) willAppearBlock
{
    _willAppearBlock = willAppearBlock;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willAppearBlock) name:FLWILLAPPEARVIEW object:nil];
}

- (void)SetDidAppearBlock:(nullable void (^)(NSDictionary * _Nonnull details)) didAppearBlock
{
    _didAppearBlock = didAppearBlock;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAppearBlock) name:FLDIDAPPEARVIEW object:nil];
}

- (void)SetWillDisappearBlock:(nullable void (^)(NSDictionary * _Nonnull details)) willDisappearBlock
{
    _willDisappearBlock = willDisappearBlock;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willDisappearBlock) name:FLWILLDISAPPEARVIEW object:nil];
}

- (void)SetDidDisappearBlock:(nullable void (^)(NSDictionary * _Nonnull details)) didDisappearBlock
{
    _didDisappearBlock = didDisappearBlock;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDisappearBlock) name:FLDIDDISAPPEARVIEW object:nil];
}

- (void)EventListener:(Event)eventAction Details:(nonnull NSDictionary *) details
{
    switch (eventAction)
    {
        case PreLoad:
            _preLoadBlock(details);
            break;
            
        case DidLoad:
            _didLoadBlock(details);
            break;
            
        case FailedLoad:
            _failedLoadBlock(details);
            break;
            
        case WillAppear:
            _willAppearBlock(details);
            break;
            
        case DidAppear:
            _didAppearBlock(details);
            break;
            
        case WillDisappear:
            _willDisappearBlock(details);
            break;
            
        case DidDisappear:
            _didDisappearBlock(details);
            break;
            
        default:
            break;
    }
}

- (void)saveCache:(nonnull NSString *)data
{
    NSError *err;
    NSDictionary *dict = [NSPropertyListSerialization propertyListWithData:[data dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions format:NULL error:&err];
    [[CacheManager sharedManager] addNewCacheModel:dict];
}

#pragma mark - Main Actions

- (void)Hide
{
	if (!_parentView || _placementStatus != Enable)
		return;
	
	[self hideContent];
}

- (void)Show
{
	if (!_parentView || _placementStatus != Enable)
		return;

	if ([internetReachabilityChecker isReachable])
		[self showOnlineContent];
	else
		[self showOfflineContent];
}

#pragma mark - Parent View Setting

- (void)SetParentView:(nonnull UIView *)view
{
    _parentView = view;
}

- (void)SetParentViewController:(nonnull UIViewController *)viewController
{
    _parentView = viewController.view;
}

- (nullable UIView *)getParentView
{
    return _parentView;
}

#pragma mark - Shoe/Hide/Remove Actions

- (void)showOnlineContent;
{
    UIWebView *placementContent = [[UIWebView alloc] init];
    placementContent = [self getOnlineModeWithContentAtURL];
    [self showWebView:placementContent InView:_placementModel.parentView PlacementHashID:_placementModel.placementHashID];
}

- (void)showOfflineContent
{
    UIWebView *placementContent = [[UIWebView alloc] init];
    placementContent = [self getOfflineModeWithContentAtURL];
    [self showWebView:placementContent InView:_placementModel.parentView PlacementHashID:_placementModel.placementHashID];
}

- (void)hideContent
{
    [self hideWebView:_placementModel.placementView PlacementHashID:_placementModel.placementHashID];
}

- (void)showWebView:(UIWebView *)webView InView:(UIView *)view PlacementHashID:(NSString *)placementHashID
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *timerKey = [FLSTORAGETIMERKEY stringByAppendingString:placementHashID];
    NSString *hiddenKey = [FLSTORAGEHIDDENKEY stringByAppendingString:placementHashID];
    
    if ([ud boolForKey:hiddenKey])
    {
        if ([ud integerForKey:timerKey] > [[NSDate date] timeIntervalSince1970])
        {
            [webView setHidden:false];
            [view addSubview:webView];
            [ud setBool:false forKey:hiddenKey];
            [ud synchronize];
        }
        else
        {
            NSDictionary *dict = [NSDictionary dictionary];
            [APIManager sendReportToBackend:dict SuccessBlock:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                
            } failedBlock:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
                
            }];
        }
    }
    else
    {
        [webView addSubview:webView];
    }
}

- (void)hideWebView:(UIWebView *)webView PlacementHashID:(NSString *)placementHashID
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *timerKey = [FLSTORAGETIMERKEY stringByAppendingString:placementHashID];
    NSString *hiddenKey = [FLSTORAGEHIDDENKEY stringByAppendingString:placementHashID];
    
    if (![ud boolForKey:hiddenKey])
    {
        int val = [[NSDate date] timeIntervalSince1970] + FLDEFAULTTIMER;
        [ud setInteger:val forKey:timerKey];
        [ud setBool:true forKey:hiddenKey];
        [ud synchronize];
        
        [webView setHidden:true];
    }
}

- (void)removePlacement
{
    [_placementModel.placementView removeFromSuperview];
}

#pragma mark - Content Setting

- (void)setOnlineModeWithContentAtURL:(nonnull NSURL *)url
{
    [_onlineQueue enqueue:url];
}

- (void)setOfflineModeWithContentAtURL:(nonnull NSURL *)url
{
    [_offlineQueue enqueue:url];
}

- (nullable UIWebView *)getOnlineModeWithContentAtURL
{
    NSURL *url = (NSURL *)[_onlineQueue dequeue];
    [_placementView loadRequest:[NSURLRequest requestWithURL:url]];
    return _placementView;
}

- (nullable UIWebView *)getOfflineModeWithContentAtURL
{
    NSURL *url = (NSURL *)[_offlineQueue dequeue];
    [_placementView loadRequest:[NSURLRequest requestWithURL:url]];
    return _placementView;
}

#pragma mark - Storage and Coding Delegates

- (void)savePlacementManager
{
    NSString *key = [NSString stringWithFormat:@"%@:%@", FLPLACEMENTMANAGERSTORAGE, _placementHashID];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:self];
    [ud setObject:encodedObject forKey:key];
    [ud synchronize];
}

- (void)loadPlacementManager
{
    NSString *key = [NSString stringWithFormat:@"%@:%@", FLPLACEMENTMANAGERSTORAGE, _placementHashID];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [ud objectForKey:key];
    self = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.placementHashID      forKey:@"PLACEMENTHASHID"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if(self)
    {
        self.placementHashID      = [decoder decodeObjectForKey:@"PLACEMENTHASHID"];
    }
    return self;
}

@end
