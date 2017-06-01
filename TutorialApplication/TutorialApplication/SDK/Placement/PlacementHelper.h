//
//  PlacementHelper.h
//  TutorialApplication
//
//  Created by Alirëza WJ Arabi on 6/1/17.
//  Copyright © 2017 Flieral Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlacementHelper : NSObject

+ (nullable PlacementHelper *)sharedHelper;

- (void)saveTimerForContent:(nonnull NSString *)contentHashId;

- (nullable NSNumber *)loadTimerForContent:(nonnull NSString *)contentHashId;

- (void)removeTimerForContent:(nonnull NSString *)contentHashId;

- (void)removeFileAtPath:(nonnull NSString *)filePath;

- (BOOL)checkForFileExistsAtPath:(nonnull NSString *)filePath;

- (void)startCleaner;

@end
