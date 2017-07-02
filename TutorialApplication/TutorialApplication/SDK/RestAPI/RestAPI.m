//
//  RestAPI.m
//  TutorialApplication
//
//  Created by Alireza Arabi on 9/17/16.
//  Copyright © 2016 Flieral Inc. All rights reserved.
//

#import "RestAPI.h"
#import "FlieralAPIManager.h"
#import "PublicHeaders.h"

@implementation RestAPI

#pragma mark - Shared Instance Singelton

+ (nonnull id)sharedService
{
    static RestAPI* sharedRestService = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedRestService = [self new];
    });
    
    return sharedRestService;
}

#pragma mark - HTTP Methods

- (void)getMethodWithQueryString:(nonnull NSString *)queryString
                      Parameters:(nullable NSObject *)parameters
                        Progress:(nullable void (^)(NSProgress  * _Nullable downloadProgress)) progressBlock
                    SuccessBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, _Nonnull id responseObject)) successBlock
                     failedBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error)) failedBlock
{
    [[FlieralAPIManager sharedManager] GET:[queryString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                parameters:parameters
                                  progress:^(NSProgress * _Nonnull downloadProgress) {
                                    
                                  } success:^(NSURLSessionDataTask *task, id responseObject) {
                                      successBlock(task, responseObject);
                                  } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      failedBlock(task, error);
                                  }];
}

- (void)putMethodWithQueryString:(nonnull NSString *)queryString
                      Parameters:(nullable NSObject *)parameters
                    SuccessBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, _Nonnull id responseObject)) successBlock
                     failedBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error)) failedBlock
{
    [[FlieralAPIManager sharedManager] PUT:[queryString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                parameters:parameters
                                   success:^(NSURLSessionDataTask *task, id responseObject) {
                                       successBlock(task, responseObject);
                                   } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                       failedBlock(task, error);
                                   }];
}

- (void)postMethodWithQueryString:(nonnull NSString *)queryString
                       Parameters:(nullable NSObject *)parameters
                         Progress:(nullable void (^)(NSProgress * _Nullable downloadProgress)) progressBlock
                     SuccessBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, _Nonnull id responseObject)) successBlock
                      failedBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error)) failedBlock
{
    [[FlieralAPIManager sharedManager] POST:[queryString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                 parameters:parameters
                                   progress:^(NSProgress * _Nonnull downloadProgress) {
                                       
                                   } success:^(NSURLSessionDataTask *task, id responseObject) {
                                       successBlock(task, responseObject);
                                   } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                       failedBlock(task, error);
                                   }];
}

- (void)deleteMethodWithQueryString:(nonnull NSString *)queryString
                         Parameters:(nullable NSObject *)parameters
                       SuccessBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, _Nonnull id responseObject)) successBlock
                        failedBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error)) failedBlock
{
    [[FlieralAPIManager sharedManager] DELETE:[queryString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                   parameters:parameters
                                      success:^(NSURLSessionDataTask *task, id responseObject) {
                                          successBlock(task, responseObject);
                                      } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                          failedBlock(task, error);
                                      }];
}

- (void)headMethodWithQueryString:(nonnull NSString *)queryString
                       Parameters:(nullable NSObject *)parameters
                     SuccessBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task)) successBlock
                      failedBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error)) failedBlock
{
    [[FlieralAPIManager sharedManager] HEAD:[queryString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                 parameters:parameters
                                    success:^(NSURLSessionDataTask *task) {
                                        successBlock(task);
                                    } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                        failedBlock(task, error);
                                    }];
}

- (void)downloadMethodWithQueryString:(nonnull NSString *)queryString
                                 Path:(nonnull NSURL *)path
                         SuccessBlock:(nullable void (^)(NSURLResponse * _Nonnull response, NSURL * _Nonnull filePath)) successBlock
                          failedBlock:(nullable void (^)(NSError * _Nonnull error)) failedBlock
{
    NSURL *URL = [NSURL URLWithString:[[NSString stringWithFormat:@"http://%@:3000/api/", SERVERADDRESS] stringByAppendingString:[queryString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];

    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL * _Nullable(NSURL * _Nullable targetPath, NSURLResponse * _Nullable response) {
        return path;
    } completionHandler:^(NSURLResponse * _Nullable response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error)
            failedBlock(error);
        successBlock(response, filePath);
    }];
    [downloadTask resume];
}

@end
