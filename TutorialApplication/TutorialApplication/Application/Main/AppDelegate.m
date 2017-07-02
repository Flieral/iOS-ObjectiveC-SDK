//
//  AppDelegate.m
//  TutorialApplication
//
//  Created by Alireza Arabi on 9/16/16.
//  Copyright © 2016 Flieral Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "FlieralSDKEngine.h"

#define PUBLISHERID             @""
#define APPLICATIONID           @""

#define FIRST_PLACEMENT         @""
#define SECOND_PLACEMENT        @""
#define THIRD_PLACEMENT         @""
#define FOURTH_PLACEMENT        @""
#define FIFTH_PLACEMENT         @""
#define SIXTH_PLACEMENT         @""
#define SEVENTH_PLACEMENT       @""


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@"true" forKey:@"logEnable"];
    
    [[FlieralSDKEngine SDKEngine] AddSetting:dict];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"placementInput" ofType:@"json"];
    [[FlieralSDKEngine SDKEngine] LoadInformationFromFile:path];
    
/*
    [[FlieralSDKEngine SDKEngine] Authenticate:PUBLISHERID ApplicationHashID:APPLICATIONID];
    
    [[FlieralSDKEngine SDKEngine] AddPlacement:FIRST_PLACEMENT];
    [[FlieralSDKEngine SDKEngine] AddPlacement:SECOND_PLACEMENT];
    [[FlieralSDKEngine SDKEngine] AddPlacement:THIRD_PLACEMENT];
    [[FlieralSDKEngine SDKEngine] AddPlacement:FOURTH_PLACEMENT];
    [[FlieralSDKEngine SDKEngine] AddPlacement:FIFTH_PLACEMENT];
    [[FlieralSDKEngine SDKEngine] AddPlacement:SIXTH_PLACEMENT];
    [[FlieralSDKEngine SDKEngine] AddPlacement:SEVENTH_PLACEMENT];
*/
    
    [[FlieralSDKEngine SDKEngine] StartEngine];

	return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
