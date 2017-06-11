//
//  APIManager.h
//  TutorialApplication
//
//  Created by Alireza Arabi on 9/18/16.
//  Copyright © 2016 Flieral Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIManager : NSObject

+ (void)sendAuthenticationToBackend:(nonnull NSMutableDictionary *)information
                       SuccessBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, _Nonnull id responseObject)) successBlock
                        failedBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error)) failedBlock;

+ (void)sendReportToBackend:(nonnull NSMutableDictionary *)information
			   SuccessBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, _Nonnull id responseObject)) successBlock
				failedBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error)) failedBlock;

+ (void)sendUserInformation:(nonnull NSMutableDictionary *)information
               SuccessBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, _Nonnull id responseObject)) successBlock
                failedBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error)) failedBlock;

+ (void)sendRequestForContent:(nonnull NSArray *)payload
                   userHashId:(nonnull NSString *)userID
                 SuccessBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, _Nonnull id responseObject)) successBlock
                  failedBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error)) failedBlock;

+ (void)getUserSettingFromIPAPISuccessBlock:(nullable void (^)(NSData * _Nonnull data, NSURLResponse * _Nonnull response)) successBlock
                                failedBlock:(nullable void (^)(NSError * _Nonnull error)) failedBlock;

+ (void)getUserHashIDWithSuccessBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, _Nonnull id responseObject)) successBlock
                          failedBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error)) failedBlock;

+ (void)downloadContentWithInformation:(nonnull NSMutableDictionary *)information
                                  Path:(nonnull NSURL *)path
                          SuccessBlock:(nullable void (^)(NSURLResponse * _Nonnull response, NSURL * _Nonnull filePath)) successBlock
                           failedBlock:(nullable void (^)(NSError * _Nonnull error)) failedBlock;

@end
