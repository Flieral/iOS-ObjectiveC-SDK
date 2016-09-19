//
//  APIManager.m
//  TutorialApplication
//
//  Created by Alireza Arabi on 9/18/16.
//  Copyright © 2016 Flieral Inc. All rights reserved.
//

#import "APIManager.h"
#import "RestAPI.h"

@implementation APIManager

+ (void)sendInformationToBackend:(nonnull NSDictionary *)information 
					SuccessBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, _Nonnull id responseObject)) successBlock
					 failedBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error)) failedBlock
{
	[[RestAPI sharedService] postMethodWithQueryString:@"" Parameters:information Progress:nil
	 
										  SuccessBlock:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
											  
											  successBlock(task, responseObject);
											  
										  }failedBlock:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
											  
											  failedBlock(task, error);
	}];
}

+ (void)sendReportToBackend:(nonnull NSDictionary *)information
			   SuccessBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, _Nonnull id responseObject)) successBlock
				failedBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error)) failedBlock
{
	[[RestAPI sharedService] postMethodWithQueryString:@"" Parameters:information Progress:nil
	 
										  SuccessBlock:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
											  
											  successBlock(task, responseObject);
											  
										  }failedBlock:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
											  
											  failedBlock(task, error);
										  }];
}

@end
