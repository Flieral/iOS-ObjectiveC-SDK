//
//  RestAPI.h
//  TutorialApplication
//
//  Created by Alireza Arabi on 9/17/16.
//  Copyright © 2016 Flieral Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RestAPI : NSObject

+ (nonnull id)sharedService;

- (void)getMethodWithQueryString:(nonnull NSString *)queryString
					  Parameters:(nullable NSObject *)parameters
						Progress:(nullable void (^)(NSProgress  * _Nullable downloadProgress)) progressBlock
					SuccessBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, _Nonnull id responseObject)) successBlock
					 failedBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error)) failedBlock;

- (void)putMethodWithQueryString:(nonnull NSString *)queryString
					  Parameters:(nullable NSObject *)parameters
					SuccessBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, _Nonnull id responseObject)) successBlock
					 failedBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error)) failedBlock;

- (void)postMethodWithQueryString:(nonnull NSString *)queryString
					   Parameters:(nullable NSObject *)parameters
						 Progress:(nullable void (^)(NSProgress * _Nullable downloadProgress)) progressBlock
					 SuccessBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, _Nonnull id responseObject)) successBlock
					  failedBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error)) failedBlock;

- (void)deleteMethodWithQueryString:(nonnull NSString *)queryString
						 Parameters:(nullable NSObject *)parameters
					   SuccessBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, _Nonnull id responseObject)) successBlock
						failedBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error)) failedBlock;

- (void)downloadMethodWithQueryString:(nonnull NSString *)queryString
                                 Path:(nonnull NSURL *)path
                         SuccessBlock:(nullable void (^)(NSURLResponse * _Nonnull response, NSURL * _Nonnull filePath)) successBlock
                          failedBlock:(nullable void (^)(NSError * _Nonnull error)) failedBlock;

@end
