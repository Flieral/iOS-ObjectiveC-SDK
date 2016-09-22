//
//  MonitorManager.h
//  TutorialApplication
//
//  Created by Alireza Arabi on 9/21/16.
//  Copyright © 2016 Flieral Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MonitorManagerDelegate <NSObject>

@required

- (void)monitoringCompleteObject:(nonnull NSDictionary *)monitor;

@optional

- (void)monitorResponse:(nonnull NSDictionary *)monitor;
- (void)networkResponse:(nonnull NSDictionary *)network;
- (void)settingResponse:(nonnull NSDictionary *)setting;

@end

@interface MonitorManager : NSObject

- (void)startPinging;

@property _Nonnull id <MonitorManagerDelegate> delegate;

@end
