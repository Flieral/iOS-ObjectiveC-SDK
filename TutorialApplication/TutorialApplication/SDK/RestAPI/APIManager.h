//
//  APIManager.h
//  TutorialApplication
//
//  Created by Alireza Arabi on 9/18/16.
//  Copyright © 2016 Flieral Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIManager : NSObject

+ (void)sendInformationToBackend:(nonnull NSDictionary *)information
					SuccessBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, _Nonnull id responseObject)) successBlock
					 failedBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error)) failedBlock;

+ (void)sendReportToBackend:(nonnull NSDictionary *)information
			   SuccessBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, _Nonnull id responseObject)) successBlock
				failedBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error)) failedBlock;

+ (void)getUserSettingFromIPAPISuccessBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, _Nonnull id responseObject)) successBlock
								failedBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error)) failedBlock

@end
