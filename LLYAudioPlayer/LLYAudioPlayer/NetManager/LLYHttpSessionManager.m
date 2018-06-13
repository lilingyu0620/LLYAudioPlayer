//
//  LLYHttpSessionManager.m
//  LLYAFNetworking
//
//  Created by lly on 2018/6/12.
//  Copyright © 2018年 lly. All rights reserved.
//

#import "LLYHttpSessionManager.h"

@interface LLYHttpSessionManager ()

@property (nonatomic, strong) AFHTTPSessionManager *httpSessionManager;
@property (nonatomic, assign) LLYHttpFileType fileType;

@end


@implementation LLYHttpSessionManager

+ (instancetype)shareInstance{
    static LLYHttpSessionManager *_llyHttpSessionManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _llyHttpSessionManager = [[LLYHttpSessionManager alloc]init];
    });
    return _llyHttpSessionManager;
}

- (instancetype)init{
    
    self = [super init];
    if (self) {
        
        _httpSessionManager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        _httpSessionManager.securityPolicy = [AFSecurityPolicy defaultPolicy];
//        [_httpSessionManager.requestSerializer setValue:nil forHTTPHeaderField:@"User-Agent"];
//        [_httpSessionManager.requestSerializer setValue:[self generateClientCookie] forHTTPHeaderField:@"Cookie"];
        
        __weak __typeof(self)weakSelf = self;
        
        [_httpSessionManager setDataTaskDidReceiveResponseBlock:^NSURLSessionResponseDisposition(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSURLResponse * _Nonnull response) {
            if (weakSelf.didReceiveResponseBlock) {
                weakSelf.didReceiveResponseBlock(session, dataTask, response);
            }
            return NSURLSessionResponseAllow;
        }];
        
        [_httpSessionManager setDataTaskDidReceiveDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSData * _Nonnull data) {
            if (weakSelf.didReceiveDataBlock) {
                weakSelf.didReceiveDataBlock(session, dataTask, data);
            }
        }];
        
        //默认json
        self.fileType = LLYHttpFileType_JSON;
    }
    return self;
}

- (void)setFileType:(LLYHttpFileType)fileType{
    
    if(fileType == _fileType){
        return;
    }
        
    _fileType = fileType;
    
    //根据不同的请求文件设置不同的解析参数
    [self setResponseSerializer:fileType];
}

- (void)setResponseSerializer:(LLYHttpFileType)fileType{
    
    switch (fileType) {
        case LLYHttpFileType_JSON:{
            _httpSessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        }
            break;
        case LLYHttpFileType_IMAGE:
        {
            _httpSessionManager.responseSerializer = [AFImageResponseSerializer serializer];
        }
            break;
        case LLYHttpFileType_AUDIO:{
            _httpSessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
            _httpSessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"audio/mpeg",nil];
        }
            break;
        case LLYHttpFileType_VIDEO:{
            _httpSessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
            _httpSessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"video/mp4",@"video/mpeg",nil];
        }
            break;
        default:
        {
            _httpSessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        }
            break;
    }
}

- (void)setValue:(id)Value forHTTPHeaderField:(NSString *)headerField{
    
    [_httpSessionManager.requestSerializer setValue:Value forHTTPHeaderField:headerField];
    
}

- (nullable NSURLSessionTask *)requestJSONWithMethod:(LLYHttpMethod)method
                                           urlString:(nullable NSString *)URLString
                                          parameters:(nullable id)parameters
                                            progress:(nullable void (^)(NSProgress * _Nullable downloadProgress))downloadProgress
                                             success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject))success
                                             failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error))failure{
    return [self requestWithMethod:method fileType:LLYHttpFileType_JSON urlString:URLString parameters:parameters progress:downloadProgress success:success failure:failure];
}

- (nullable NSURLSessionTask *)requestIMAGEWithMethod:(LLYHttpMethod)method
                                            urlString:(nullable NSString *)URLString
                                           parameters:(nullable id)parameters
                                             progress:(nullable void (^)(NSProgress * _Nullable downloadProgress))downloadProgress
                                              success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject))success
                                              failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error))failure{
    return [self requestWithMethod:method fileType:LLYHttpFileType_IMAGE urlString:URLString parameters:parameters progress:downloadProgress success:success failure:failure];
}

- (nullable NSURLSessionTask *)requestAUDIOWithMethod:(LLYHttpMethod)method
                                            urlString:(nullable NSString *)URLString
                                           parameters:(nullable id)parameters
                                             progress:(nullable void (^)(NSProgress * _Nullable downloadProgress))downloadProgress
                                              success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject))success
                                              failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error))failure{
    return [self requestWithMethod:method fileType:LLYHttpFileType_AUDIO urlString:URLString parameters:parameters progress:downloadProgress success:success failure:failure];
}

- (nullable NSURLSessionTask *)requestVIDEOWithMethod:(LLYHttpMethod)method
                                            urlString:(nullable NSString *)URLString
                                           parameters:(nullable id)parameters
                                             progress:(nullable void (^)(NSProgress * _Nullable downloadProgress))downloadProgress
                                              success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject))success
                                              failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error))failure{
    return [self requestWithMethod:method fileType:LLYHttpFileType_VIDEO urlString:URLString parameters:parameters progress:downloadProgress success:success failure:failure];
}

- (nullable NSURLSessionTask *)requestWithMethod:(LLYHttpMethod)method
                                        fileType:(LLYHttpFileType)fileType
                                       urlString:(NSString *)URLString
                                      parameters:(nullable id)parameters
                                        progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                                         success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                         failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
    
    self.fileType = fileType;
    
    NSURLSessionTask *task = nil;
    
    switch (method) {
        case LLYHttpMethod_GET:
        {
            task = [_httpSessionManager GET:URLString parameters:parameters progress:downloadProgress success:success failure:failure];
        }
            break;
            
        case LLYHttpMethod_POST:
        {
            task = [_httpSessionManager POST:URLString parameters:parameters progress:downloadProgress success:success failure:failure];
        }
            break;
            
        case LLYHttpMethod_HEAD:
        {
            task = [_httpSessionManager HEAD:URLString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task) {
                if (success) {
                    success(task,nil);
                }
            } failure:failure];
        }
            break;
            
        default:
            break;
    }
    
    return task;
}

- (NSURLSessionDownloadTask *)downloadWithUrl:(NSString *)urlString
                                     progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                  destination:(nullable NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                            completionHandler:(nullable void (^)(NSURLResponse *response, NSURL * _Nullable filePath, NSError * _Nullable error))completionHandler{
    NSURLSessionDownloadTask *task = nil;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    task = [_httpSessionManager downloadTaskWithRequest:request progress:downloadProgressBlock destination:destination completionHandler:completionHandler];
    
    [task resume];
    
    return task;
}



@end
