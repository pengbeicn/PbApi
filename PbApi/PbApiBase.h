//
//  PbApi.h
//  PbApi
//
//  Created by 彭 on 16/4/2.
//  Copyright © 2016年 devteam. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    PbRequestMethodUnknown,
    PbRequestMethodGet,
    PbRequestMethodPost,
    PbRequestMethodPut,
    PbRequestMethodDelete,
} PbRequestMethod;

typedef void (^RequestBlock)(NSDictionary* result, NSError* error);

@interface PbApiBase : NSObject

/*
 默认的调用请求方法
 */
+ (id)requestWithParam:(NSDictionary*)param completion:(RequestBlock)completion;

/*
 使用指定方法来调用请求
 此时会在请求时会忽略method方法
 */
+ (id)getWithParam:(NSDictionary*)param completion:(RequestBlock)completion;
+ (id)postWithParam:(NSDictionary*)param completion:(RequestBlock)completion;
+ (id)putWithParam:(NSDictionary*)param completion:(RequestBlock)completion;
+ (id)deleteWithParam:(NSDictionary*)param completion:(RequestBlock)completion;

#pragma mark 必须继承的方法
/*
 域名
 需要带http:// 或 https://
 */
- (NSString*)domain;

/*
 api名
 如："user_info"，前后不需要带/
 */
- (NSString*)name;

/*
 请求的方法，默认为Get
 如果返回PbRequestMethodUnknown，会使用默认的Get
 
 如果是使用的requestWithParam::来调用请求，会忽略此方法
 */
- (PbRequestMethod)method;

#pragma mark 按需继承的方法
/*
 url前缀
 如："api/v1"，默认为""
 */
- (NSString*)prefix;

/*
 url后缀
 如：".json"，默认为""
 */
- (NSString*)suffix;

/*
 请求的头，默认为nil
 */
- (NSDictionary*)header;

/*
 将请求的json转换成自定义的格式，默认不转换
 */
- (NSDictionary*)result:(NSDictionary*)json;

#pragma mark - 回调事件
- (void)willRequestWithURLString:(NSString*)URLString;

- (void)didRequestSuccessWithResult:(NSDictionary*)result response:(NSHTTPURLResponse*)response;
- (void)didRequestFailureWithResponse:(NSHTTPURLResponse*)response error:(NSError*)error;

@end
