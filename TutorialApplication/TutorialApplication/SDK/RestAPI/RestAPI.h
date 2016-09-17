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
					  Parameters:(nullable NSDictionary *)parameters
						Progress:(nullable void (^)(NSProgress  * _Nonnull downloadProgress)) progressBlock
					SuccessBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, _Nonnull id responseObject)) successBlock
					 failedBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error)) failedBlock;

- (void)putMethodWithQueryString:(nonnull NSString *)queryString
					  Parameters:(nullable NSDictionary *)parameters
					SuccessBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, _Nonnull id responseObject)) successBlock
					 failedBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error)) failedBlock;

- (void)postMethodWithQueryString:(nonnull NSString *)queryString
					   Parameters:(nullable NSDictionary *)parameters
						 Progress:(nullable void (^)(NSProgress * _Nonnull downloadProgress)) progressBlock
					 SuccessBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, _Nonnull id responseObject)) successBlock
					  failedBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error)) failedBlock;

- (void)deleteMethodWithQueryString:(nonnull NSString *)queryString
						 Parameters:(nullable NSDictionary *)parameters
					   SuccessBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, _Nonnull id responseObject)) successBlock
						failedBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error)) failedBlock;

- (void)headMethodWithQueryString:(nonnull NSString *)queryString
					   Parameters:(nullable NSDictionary *)parameters
					 SuccessBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task)) successBlock
					  failedBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error)) failedBlock;

@end
