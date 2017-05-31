//
//  UserManager.m
//  TutorialApplication
//
//  Created by Alirëza WJ Arabi on 5/28/17.
//  Copyright © 2017 Flieral Inc. All rights reserved.
//

#import "UserManager.h"
#import "PublicHeaders.h"
#import "APIManager.h"
#import "APIManager.h"
#import "Reachability.h"
#import <sys/utsname.h>

#define UserKEY				@"SettingStorageKey"

@interface UserManager ()
{
    Reachability *internetReachabilityChecker;
}

@property (nonnull, nonatomic, strong) __block NSDictionary *settingDict;

@property (nonatomic) BOOL settingReady;

@end

@implementation UserManager

- (nonnull instancetype)init
{
    self = [super init];
    if (self)
    {
        internetReachabilityChecker = [Reachability reachabilityForInternetConnection];
        
        _settingDict = [NSDictionary dictionary];
        
        [_settingDict setValue:[self getLanguageCode] forKey:@"language"];
        [_settingDict setValue:[self getDevice] forKey:@"device"];
        [_settingDict setValue:[self getOS] forKey:@"os"];
        [_settingDict setValue:[self getConnection] forKey:@"connection"];
        
        [_settingDict setValue:@"US" forKey:@"country"];
        [_settingDict setValue:@"New York" forKey:@"city"];
        [_settingDict setValue:@"WestHost" forKey:@"ISP"];
        [_settingDict setValue:@"0.0.0.0" forKey:@"ip"];
        
        [self saveData];
    }
    return self;
}

#pragma mark - User Issue

- (void)startSetting
{
    _settingReady = false;
    
    [self startUserSetting];
}

#pragma mark - User & Delegate

- (void)startUserSetting
{
    [APIManager getUserSettingFromIPAPISuccessBlock:^(NSData * _Nonnull data, NSURLResponse * _Nonnull response) {

        NSError *errorJson;
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorJson];
        
        [_settingDict setValue:[responseDict valueForKey:@"countryCode"] forKey:@"country"];
        [_settingDict setValue:[responseDict valueForKey:@"regionName"] forKey:@"city"];
        [_settingDict setValue:[responseDict valueForKey:@"isp"] forKey:@"ISP"];
        [_settingDict setValue:[responseDict valueForKey:@"query"] forKey:@"ip"];
        
        [self saveData];
        
        [_delegate settingResponse:_settingDict];
        _settingReady = true;
        
    } failedBlock:^(NSError * _Nonnull error) {
        
        NSLog(@"Failed to Start: %@", error);
    }];
}

- (void)saveData
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:_settingDict forKey:UserKEY];
    [ud synchronize];
}

#pragma makr - Public Setting

- (NSString *)getLanguageCode
{
    return [[[NSLocale preferredLanguages] objectAtIndex:0] uppercaseString];
}

- (NSString *)getDevice
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [self platformType:[NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding]];
}

- (NSString *)getOS
{
    return @"iOS";
}

- (NSString *)getConnection
{
    NetworkStatus status = [internetReachabilityChecker currentReachabilityStatus];
    [internetReachabilityChecker startNotifier];
    
    if (status == ReachableViaWiFi)
        return @"WiFi";
    else if (status == ReachableViaWWAN)
        return @"Cellular";
    return @"No Internet";
}

#pragma mark - Environment Variables

- (void)setUserHashID:(nonnull NSString *)hashID
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setValue:hashID forKey:FLUSERHASHID];
    [ud synchronize];
}

- (nullable NSString *)getUserHashID
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud valueForKey:FLUSERHASHID];
}

- (Boolean)checkUserHashID
{
    if ([self getUserHashID] == (id)[NSNull null])
        return false;
    return true;
}

#pragma mark - User Setting

- (nullable NSDictionary *)getUserSetting
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud objectForKey:UserKEY];
}

#pragma mark - Helpers

- (NSString *)platformType:(NSString *)platform
{
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([platform isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    if ([platform isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
    if ([platform isEqualToString:@"iPhone9,3"])    return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3 (GSM)";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([platform isEqualToString:@"iPad4,3"])      return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,4"])      return @"iPad Mini 2G (WiFi)";
    if ([platform isEqualToString:@"iPad4,5"])      return @"iPad Mini 2G (Cellular)";
    if ([platform isEqualToString:@"iPad4,6"])      return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,7"])      return @"iPad Mini 3 (WiFi)";
    if ([platform isEqualToString:@"iPad4,8"])      return @"iPad Mini 3 (Cellular)";
    if ([platform isEqualToString:@"iPad4,9"])      return @"iPad Mini 3 (China)";
    if ([platform isEqualToString:@"iPad5,3"])      return @"iPad Air 2 (WiFi)";
    if ([platform isEqualToString:@"iPad5,4"])      return @"iPad Air 2 (Cellular)";
    if ([platform isEqualToString:@"AppleTV2,1"])   return @"Apple TV 2G";
    if ([platform isEqualToString:@"AppleTV3,1"])   return @"Apple TV 3";
    if ([platform isEqualToString:@"AppleTV3,2"])   return @"Apple TV 3 (2013)";
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    return platform;
}

@end
