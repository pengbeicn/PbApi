//
//  PbApiBase.m
//  PbApiBase
//
//  Created by 彭 on 16/4/2.
//  Copyright © 2016年 devteam. All rights reserved.
//

#import "PbApiBase.h"
#import "AFNetworking.h"

typedef enum : NSUInteger {
    PbRequestMethodGet,
    PbRequestMethodPost,
    PbRequestMethodPut,
    PbRequestMethodDelete,
} PbRequestMethod;

@interface PbApiBase ()

@property (nonatomic, assign) PbRequestMethod method;
@property (nonatomic, strong) NSDictionary* param;
@property (nonatomic, copy) RequestBlock completion;

@end

@implementation PbApiBase

+ (id)getWithParam:(NSDictionary*)param completion:(RequestBlock)completion {
    return [[self alloc]initWithMethod:PbRequestMethodGet Param:param completion:completion];
}

+ (id)postWithParam:(NSDictionary*)param completion:(RequestBlock)completion {
    return [[self alloc]initWithMethod:PbRequestMethodPost Param:param completion:completion];
}

+ (id)putWithParam:(NSDictionary*)param completion:(RequestBlock)completion {
    return [[self alloc]initWithMethod:PbRequestMethodPut Param:param completion:completion];
}

+ (id)deleteWithParam:(NSDictionary*)param completion:(RequestBlock)completion {
    return [[self alloc]initWithMethod:PbRequestMethodDelete Param:param completion:completion];
}

- (id)initWithMethod:(PbRequestMethod)method Param:(NSDictionary*)param completion:(RequestBlock)completion {
    if (self = [super init]) {
        self.method = method;
        self.param = param;
        self.completion = completion;
        
        [self start];
    }
    
    return self;
}

- (id)start {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* domain = [self domain];
        NSString* name = [self name];
        NSString* prefix = [self prefix];
        NSString* suffix = [self suffix];
        
        domain = [self removeUrlSuffix:domain];
        
        name = [self removeUrlPrefix:name];
        
        prefix = [self removeUrlPrefix:prefix];
        prefix = [self removeUrlSuffix:prefix];
        
        AFHTTPSessionManager* sessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:nil];
        sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        NSDictionary* header = [self header];
        
        for (NSString* headerKey in header.allKeys) {
            NSString* headerValue = [header objectForKey:headerKey];
            [sessionManager.requestSerializer setValue:headerValue forHTTPHeaderField:headerKey];
        }
        
        NSMutableString* url = [NSMutableString stringWithString:domain];
        
        if (prefix && prefix.length) {
            [url appendFormat:@"/%@", prefix];
        }
        
        [url appendFormat:@"/%@", name];
        
        if (suffix && suffix.length) {
            [url appendString:suffix];
        }
        
        if (self.method == PbRequestMethodGet && self.param) {
            [url appendString:[self paramToUrlString:self.param]];
        }
        
        void(^onSuccess)(NSURLSessionDataTask*, NSDictionary*, NSError*) = ^(NSURLSessionDataTask* session, NSDictionary* result, NSError* error) {
            NSDictionary *dic = [self result:result];
            
            [self didRequestSuccessWithResult:dic response:(NSHTTPURLResponse*)session.response];
            
            if (self.completion) {
                self.completion(dic, error);
            }
        };
        
        void(^onFailed)(NSURLSessionDataTask*, NSDictionary*, NSError*) = ^(NSURLSessionDataTask* response, NSDictionary* result, NSError* error) {
            [self didRequestFailureWithResponse:(NSHTTPURLResponse*)response.response error:error];
            
            if (self.completion) {
                self.completion(result, error);
            }
        };
        
        NSString* encodedUrl;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            encodedUrl = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        }
        else {
            encodedUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        
        [self willRequestWithURLString:encodedUrl];
        
        if (self.method == PbRequestMethodPost) {
            [sessionManager POST:encodedUrl parameters:self.param progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                onSuccess(task, responseObject, nil);
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                onFailed(task, nil, error);
            }];
        }
        else if (self.method == PbRequestMethodGet) {
            [sessionManager GET:encodedUrl parameters:self.param progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                onSuccess(task, responseObject, nil);
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                onFailed(task, nil, error);
            }];
        }
        else if (self.method == PbRequestMethodDelete) {
            [sessionManager DELETE:encodedUrl parameters:self.param success:^(NSURLSessionDataTask *task, id responseObject) {
                onSuccess(task, responseObject, nil);
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                onFailed(task, nil, error);
            }];
        }
        else if (self.method == PbRequestMethodPut) {
            [sessionManager PUT:encodedUrl parameters:self.param success:^(NSURLSessionDataTask *task, id responseObject) {
                onSuccess(task, responseObject, nil);
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                onFailed(task, nil, error);
            }];
        }
    });
    
    return self;
}

#pragma mark Method to be implementation
- (NSString*)domain {
    [NSException raise:@"PbApi Error" format:@"Method 'domain' not implemented"];
    return @"";
}

- (NSString*)name {
    [NSException raise:@"PbApi Error" format:@"Method 'name' not implemented"];
    return @"";
}

- (NSString*)prefix {
    return @"";
}

- (NSString*)suffix {
    return @"";
}

- (NSDictionary*)header {
    return nil;
}

- (NSDictionary*)result:(NSDictionary*)json {
    return json;
}

- (void)willRequestWithURLString:(NSString*)URLString {
    
}

- (void)didRequestSuccessWithResult:(NSDictionary*)result response:(NSHTTPURLResponse*)response {
    
}

- (void)didRequestFailureWithResponse:(NSHTTPURLResponse*)response error:(NSError*)error {
    
}

#pragma mark - Utils
- (NSString*)removeUrlPrefix:(NSString*)url {
    if (!url || !url.length) {
        return url;
    }
    
    while ([[url substringToIndex:1] isEqualToString:@"/"]) {
        url = [url substringFromIndex:1];
    }
    
    return url;
}

- (NSString*)removeUrlSuffix:(NSString*)url {
    if (!url || !url.length) {
        return url;
    }
    
    while ([[url substringFromIndex:url.length-1] isEqualToString:@"/"]) {
        url = [url substringToIndex:url.length-1];
    }
    
    return url;
}

- (NSString*)paramToUrlString:(NSDictionary*)param {
    NSMutableString *result = [[NSMutableString alloc] init];
    for (NSInteger i = 0; i < param.count; i++) {
        NSString *key = [param.allKeys objectAtIndex:i];
        NSString *value = param[key];
        if ([value isKindOfClass:[NSNumber class]]) {
            value = [((NSNumber*)value)stringValue];
        }
        if (i == 0) {
            [result appendString:@"?"];
        }
        else {
            [result appendString:@"&"];
        }
        
        [result appendFormat:@"%@=%@", key, value];
    }
    return result;
}

@end
