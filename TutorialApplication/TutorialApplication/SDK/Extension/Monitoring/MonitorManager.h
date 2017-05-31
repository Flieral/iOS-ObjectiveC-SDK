//
//  MonitorManager.h
//  TutorialApplication
//
//  Created by Alireza Arabi on 9/21/16.
//  Copyright © 2016 Flieral Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MonitorManagerDelegate <NSObject>

@optional

- (void)monitorResponse:(nonnull NSDictionary *)monitor;

@end

@interface MonitorManager : NSObject

@property _Nonnull id <MonitorManagerDelegate> delegate;

- (nonnull instancetype)init;

- (void)startPinging;

- (nullable NSDictionary *)getMonitorSetting;

@end
