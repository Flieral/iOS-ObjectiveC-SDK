//
//  FlieralAPIManager.h
//  TutorialApplication
//
//  Created by Alireza Arabi on 9/17/16.
//  Copyright © 2016 Flieral Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFHTTPSessionManager.h>

@interface FlieralAPIManager : AFHTTPSessionManager

+ (FlieralAPIManager *)sharedManager;

@end
