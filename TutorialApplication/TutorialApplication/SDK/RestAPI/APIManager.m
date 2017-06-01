//
//  APIManager.m
//  TutorialApplication
//
//  Created by Alireza Arabi on 9/18/16.
//  Copyright © 2016 Flieral Inc. All rights reserved.
//

#import "APIManager.h"
#import "RestAPI.h"
#import "PublicHeaders.h"

@implementation APIManager

+ (void)sendAuthenticationToBackend:(nonnull NSDictionary *)information
                       SuccessBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, _Nonnull id responseObject)) successBlock
                        failedBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error)) failedBlock
{
    NSString *queryString = [NSString stringWithFormat:@"?publisherHashId=%@&applicationHashId=%@", [information valueForKey:FLPUBLISHERHASHIDKEY], [information valueForKey:FLAPPLICATIONHASHIDKEY]];
    
    [[RestAPI sharedService] postMethodWithQueryString:[@"/contentManager/authorization" stringByAppendingString:queryString] Parameters:information Progress:nil SuccessBlock:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        successBlock(task, responseObject);
        
    }failedBlock:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        
        failedBlock(task, error);
    }];
}

+ (void)sendReportToBackend:(nonnull NSDictionary *)information
               SuccessBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, _Nonnull id responseObject)) successBlock
                failedBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error)) failedBlock
{
    [[RestAPI sharedService] postMethodWithQueryString:@"/statistics" Parameters:information Progress:nil SuccessBlock:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        successBlock(task, responseObject);
        
    }failedBlock:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        
        failedBlock(task, error);
    }];
}

+ (void)sendRequestForContent:(nonnull NSArray *)payload
                 SuccessBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, _Nonnull id responseObject)) successBlock
                  failedBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error)) failedBlock
{
    [[RestAPI sharedService] postMethodWithQueryString:@"/contentManager/requestForContent" Parameters:payload Progress:nil SuccessBlock:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        successBlock(task, responseObject);
        
    }failedBlock:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        
        failedBlock(task, error);
    }];
}

+ (void)sendUserInformation:(nonnull NSDictionary *)information
               SuccessBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, _Nonnull id responseObject)) successBlock
                failedBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error)) failedBlock
{
    NSString *userID = [information valueForKey:@"userId"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:information];
    [dict removeObjectForKey:@"userId"];
    
    [[RestAPI sharedService] putMethodWithQueryString:[@"/interactions/saveInformation" stringByAppendingFormat:@"?userId=%@", userID] Parameters:dict SuccessBlock:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        successBlock(task, responseObject);
        
    }failedBlock:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        
        failedBlock(task, error);
    }];
}

+ (void)getUserSettingFromIPAPISuccessBlock:(nullable void (^)(NSData * _Nonnull data, NSURLResponse * _Nonnull response)) successBlock
                                failedBlock:(nullable void (^)(NSError * _Nonnull error)) failedBlock
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"http://ip-api.com/json"]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error)
            failedBlock(error);
        else
            successBlock(data, response);
            
    }] resume];    
}

+ (void)getUserHashIDWithSuccessBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, _Nonnull id responseObject)) successBlock
                          failedBlock:(nullable void (^)(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error)) failedBlock
{
    [[RestAPI sharedService] getMethodWithQueryString:@"/interactions/generateUserHashId" Parameters:nil Progress:nil SuccessBlock:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        successBlock(task, responseObject);
        
    } failedBlock:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        
        failedBlock(task, error);
    }];
}

+ (void)downloadContentWithInformation:(nonnull NSDictionary *)information
                                  Path:(nonnull NSURL *)path
                          SuccessBlock:(nullable void (^)(NSURLResponse * _Nonnull response, NSURL * _Nonnull filePath)) successBlock
                           failedBlock:(nullable void (^)(NSError * _Nonnull error)) failedBlock
{
    NSString *url = [NSString stringWithFormat:@"/containers/%@/download/%@", [information valueForKey:@""], [information valueForKey:@""]];
    [[RestAPI sharedService] downloadMethodWithQueryString:url Path:path SuccessBlock:^(NSURLResponse * _Nonnull response, NSURL * _Nonnull filePath) {
        
        successBlock(response, filePath);
        
    } failedBlock:^(NSError * _Nonnull error) {
        
        failedBlock(error);
    }];
}


@end
