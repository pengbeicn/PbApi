//
//  PbApiBase.m
//  PbApiBase
//
//  Created by 彭 on 16/4/2.
//  Copyright © 2016年 devteam. All rights reserved.
//

#import "PbApiBase.h"
#import "AFNetworking.h"

@interface PbApiBase ()

@property (nonatomic, strong) NSDictionary* params;

@end

@implementation PbApiBase

+ (id)requestBlock:(RequestBlock)block {
    return [[self alloc]initWithBlock:block];
}

+ (id)requestWithParam:(NSDictionary*)param {
    return [[self alloc]initWithParam:param];
}

+ (id)requestWithParam:(NSDictionary*)param block:(RequestBlock)block {
    return [[self alloc]initWithParam:param block:block];
}

- (id)initWithBlock:(RequestBlock)block {
    if (self = [super init]) {
        self.block = block;
        
        [self start];
    }
    
    return self;
}

- (id)initWithParam:(NSDictionary*)param {
    return [self initWithParam:param block:nil];
}

- (id)initWithParam:(NSDictionary*)param block:(RequestBlock)block {
    self.params = param;
    return [self initWithBlock:block];
}

- (NSString*) removeUrlPrefix:(NSString*)url {
    while ([[url substringToIndex:1] isEqualToString:@"/"]) {
        url = [url substringFromIndex:1];
    }
    
    return url;
}

- (NSString*) removeUrlSuffix:(NSString*)url {
    while ([[url substringFromIndex:url.length-1] isEqualToString:@"/"]) {
        url = [url substringToIndex:url.length-1];
    }
    
    return url;
}

- (id)start {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* domain = [self domain];
        NSString* prefix = [self prefixUrl];
        NSString* suburl = [self subUrl];
        
        domain = [self removeUrlSuffix:domain];
        
        prefix = [self removeUrlPrefix:prefix];
        prefix = [self removeUrlSuffix:prefix];
        
        suburl = [self removeUrlPrefix:suburl];
        
        PbRequestMethod method = [self method];
        NSDictionary* param = [self param];
        
        AFHTTPSessionManager* sessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:nil];
        sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        NSDictionary* header = [self header];
        
        for (NSString* headerKey in header.allKeys) {
            NSString* headerValue = [header objectForKey:headerKey];
            [sessionManager.requestSerializer setValue:headerValue forHTTPHeaderField:headerKey];
        }
        
        NSString* url = [NSString stringWithFormat:@"%@/%@/%@", domain, prefix, suburl];
        if (method == PbRequestMethodGet && param) {
            url = [url stringByAppendingString:[self paramToUrlString:param]];
        }
        
        void(^checkResponse)(NSHTTPURLResponse*) = ^(NSHTTPURLResponse* response) {
            NSInteger code = response.statusCode;
            
            // TODO: 检查请求结果
        };
        
        void(^onSuccess)(NSURLSessionDataTask*, NSDictionary*, NSError*) = ^(NSURLSessionDataTask* session, NSDictionary* result, NSError* error) {
            NSDictionary *dic = [self result:result];
            if (self.block) {
                self.block(dic, error);
            }
            
            checkResponse((NSHTTPURLResponse*)session.response);
        };
        
        void(^onFailed)(NSURLSessionDataTask*, NSDictionary*, NSError*) = ^(NSURLSessionDataTask* response, NSDictionary* result, NSError* error) {
            NSLog(@"*** Request Failed: %@", error.description);
            
            if (self.block) {
                self.block(result, error);
            }
            
            checkResponse((NSHTTPURLResponse*)response.response);
        };
        
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        if (method == PbRequestMethodPost) {
            [sessionManager POST:url parameters:param progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                onSuccess(task, responseObject, nil);
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                onFailed(task, nil, error);
            }];
        }
        else if (method == PbRequestMethodGet) {
            [sessionManager GET:url parameters:param progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                onSuccess(task, responseObject, nil);
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                onFailed(task, nil, error);
            }];
        }
        else if (method == PbRequestMethodDelete) {
            [sessionManager DELETE:url parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
                onSuccess(task, responseObject, nil);
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                onFailed(task, nil, error);
            }];
        }
        else if (method == PbRequestMethodPut) {
            [sessionManager PUT:url parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
                onSuccess(task, responseObject, nil);
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                onFailed(task, nil, error);
            }];
        }
    });
    
    return self;
}

#pragma mark Method to be implementation
- (NSString*) subUrl {
    return @"";
}

- (NSString*) prefixUrl {
    return @"";
}

- (NSString*) domain {
    return @"";
}

- (PbRequestMethod) method {
    return PbRequestMethodPost;
}

- (NSDictionary*) header {
    return nil;
}

- (NSDictionary*) param {
    return self.params;
}

- (NSDictionary*) result:(NSDictionary*)json {
    return json;
}

- (NSString*)paramToUrlString:(NSDictionary*)param {
    NSMutableString *sRet = [[NSMutableString alloc] init];
    for (NSInteger i=0; i<[param count]; i++) {
        NSString *sKey = [param.allKeys objectAtIndex:i];
        NSString *sValue = param[sKey];
        if ([sValue isKindOfClass:[NSNumber class]]) {
            NSNumber *value = (NSNumber *)sValue;
            sValue = [value stringValue];
        }
        if (i==0) {
            [sRet appendString:@"?"];
        }
        else {
            [sRet appendString:@"&"];
        }
        
        [sRet appendFormat:@"%@=%@", sKey, sValue];
    }
    return sRet;
}

@end
