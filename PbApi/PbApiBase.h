//
//  PbApi.h
//  PbApi
//
//  Created by 彭 on 16/4/2.
//  Copyright © 2016年 devteam. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^RequestBlock)(NSDictionary* result, NSError* error);

@interface PbApiBase : NSObject

+ (id)getWithParam:(NSDictionary*)param completion:(RequestBlock)completion;
+ (id)postWithParam:(NSDictionary*)param completion:(RequestBlock)completion;
+ (id)putWithParam:(NSDictionary*)param completion:(RequestBlock)completion;
+ (id)deleteWithParam:(NSDictionary*)param completion:(RequestBlock)completion;

#pragma mark 必须继承的方法
// 域名，需要带http:// 或 https://
- (NSString*)domain;

// api名，如："user_info"，前后不需要带/
- (NSString*)name;

#pragma mark 按需继承的方法
// url前缀，如："api/v1"，默认为""
- (NSString*)prefix;

// url后缀，如：".json"，默认为""
- (NSString*)suffix;

// 请求的头，默认为nil
- (NSDictionary*)header;

// 将请求的json转换成自定义的格式，默认不转换
- (NSDictionary*)result:(NSDictionary*)json;

#pragma mark - 回调事件
- (void)willRequestWithURLString:(NSString*)URLString;

- (void)didRequestSuccessWithResult:(NSDictionary*)result response:(NSHTTPURLResponse*)response;
- (void)didRequestFailureWithResponse:(NSHTTPURLResponse*)response error:(NSError*)error;

@end
