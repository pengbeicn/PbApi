# PbApi

## 安装

通过 CocoaPods

```ruby
pod "PbApi"
```

## 使用方法
使用PbApi时，每个api即为一个类，继承自PbApiBase类，并重写指定方法来配置api。

### 创建Api基类
建议创建自己的基类来配置基本信息，如设置服务器域名、设置请求的header、设置api的前缀（如/api/v1）。

例如创建基类名为MyApiBase

基类h文件
```Objective-C
#import "PbApi.h"
@interface MyApiBase : PbApiBase
@end
```

基类m文件
```Objective-C
#import "MyApiBase.h"

@implementation MyApiBase

/*
 必须重写的方法
 设置api的域名，需要带http:// 或 https://
 */
- (NSString *)domain {
    return @"http://api.mydomain.com";
}

/*
 url前缀
 */
- (NSString *)prefix {
    return @"api/v1";
}

/*
 url后缀
 */
- (NSString*)suffix {
    return @".json";
}

/*
 请求的头数据
 */
- (NSDictionary*)header {
    return @{@"Authorization": @"Token xxx"};
}

/*
 当请求失败时，将会有此回调，用于检查错误码
 */
- (void)didRequestFailureWithResponse:(NSHTTPURLResponse*)response error:(NSError*)error {
    NSInteger statusCode = response.statusCode;
    ...
}

@end
```

### 创建Api

例如创建Api用于请求用户信息，基于基类MyApiBase。

Api h文件
```Objective-C
#import "MyApiBase.h"

@interface MyApiGetUserInfo : MyApiBase

@end
```

Api m文件
```Objective-C
#import "MyApiGetUserInfo.h"

@implementation MyApiGetUserInfo

/*
 必须重写的方法
 设置api名
 */
- (NSString *)name {
    return @"user_info";
}

/*
 配置默认的请求方法，也可以不重写此方法来使用默认的PbRequestMethodGet
 */
- (PbRequestMethod)method {
    return PbRequestMethodGet;
}

/*
 将请求成功之后的json转换成自定义的格式并返回。例如转换为自定义的Model，也可以不重写此方法来默认使用json作为结果返回
 */
- (NSDictionary*)result:(NSDictionary*)json {
    ...
    return json;
}

/*
 以下为回调事件
 */
- (void)willRequestWithURLString:(NSString*)URLString {
    [super willRequestWithURLString:URLString];
}

- (void)didRequestSuccessWithResult:(NSDictionary*)result response:(NSHTTPURLResponse*)response {
    [super didRequestSuccessWithResult:result response:response];
}

- (void)didRequestFailureWithResponse:(NSHTTPURLResponse*)response error:(NSError*)error {
    [super didRequestFailureWithResponse:response error:error];
}

@end
```

### 使用方法

调用Api

使用默认方法请求，默认请求方法为类中配置的PbRequestMethodGet。
```Objective-C
[MyApiGetUserInfo requestWithParam:@{@"username": @"admin"} completion:^(NSDictionary *result, NSError *error) {
    if (error) {
        return;
    }

    ...
}];
```
使用指定方法请求
- getWithParam
- postWithParam
- putWithParam
- deleteWithParam

此时将忽略Api类中配置的方法

```Objective-C
[MyApiGetUserInfo getWithParam:@{@"username": @"admin"} completion:^(NSDictionary *result, NSError *error) {
    if (error) {
        return;
    }

    ...
}];
```
