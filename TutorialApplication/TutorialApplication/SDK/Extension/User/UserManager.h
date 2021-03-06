//
//  UserManager.h
//  TutorialApplication
//
//  Created by Alirëza WJ Arabi on 5/28/17.
//  Copyright © 2017 Flieral Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UserManagerDelegate <NSObject>

@optional

- (void)settingResponse:(nonnull NSMutableDictionary *)setting;

@end

@interface UserManager : NSObject

@property _Nonnull id <UserManagerDelegate> delegate;

- (nonnull instancetype)init;

- (void)startSetting;

- (nullable NSMutableDictionary *)getUserSetting;

+ (nullable NSMutableDictionary *)getUserPublicSetting;

- (void)setUserHashID:(nonnull NSString *)hashID;

- (nullable NSString *)getUserHashID;

+ (nullable NSString *)getUserHashID;

- (BOOL)checkUserHashID;

- (void)setAuthenticationAndPlacementManagerEnable;

- (BOOL)checkForAuthenticationAndPlacementManager;

@end
