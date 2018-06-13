//
//  LLYHttpSessionManager.h
//  LLYAFNetworking
//
//  Created by lly on 2018/6/12.
//  Copyright © 2018年 lly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

typedef void (^DidReceiveResponseBlock)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLResponse *response);
typedef void (^DidBecomeDownloadTaskBlock) (NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLSessionDownloadTask *downloadTask);
typedef void (^DidReceiveDataBlock) (NSURLSession *session, NSURLSessionDataTask *dataTask, NSData *data);


typedef NS_ENUM(NSUInteger, LLYHttpMethod) {
    LLYHttpMethod_GET = 0,
    LLYHttpMethod_POST,
    LLYHttpMethod_HEAD,
};

typedef NS_ENUM(NSUInteger, LLYHttpFileType) {
    LLYHttpFileType_JSON = 0,
    LLYHttpFileType_IMAGE,
    LLYHttpFileType_AUDIO,
    LLYHttpFileType_VIDEO
};


@interface LLYHttpSessionManager : NSObject

@property (nonatomic, copy) DidReceiveResponseBlock didReceiveResponseBlock;
@property (nonatomic, copy) DidReceiveDataBlock didReceiveDataBlock;


+ (instancetype)shareInstance;

- (void)setValue:(id)Value forHTTPHeaderField:(NSString *)headerField;

- (nullable NSURLSessionTask *)requestJSONWithMethod:(LLYHttpMethod)method
                                       urlString:(nullable NSString *)URLString
                                      parameters:(nullable id)parameters
                                        progress:(nullable void (^)(NSProgress * _Nullable downloadProgress))downloadProgress
                                         success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject))success
                                             failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error))failure;

- (nullable NSURLSessionTask *)requestIMAGEWithMethod:(LLYHttpMethod)method
                                           urlString:(nullable NSString *)URLString
                                          parameters:(nullable id)parameters
                                            progress:(nullable void (^)(NSProgress * _Nullable downloadProgress))downloadProgress
                                             success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject))success
                                             failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error))failure;

- (nullable NSURLSessionTask *)requestAUDIOWithMethod:(LLYHttpMethod)method
                                            urlString:(nullable NSString *)URLString
                                           parameters:(nullable id)parameters
                                             progress:(nullable void (^)(NSProgress * _Nullable downloadProgress))downloadProgress
                                              success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject))success
                                              failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error))failure;

- (nullable NSURLSessionTask *)requestVIDEOWithMethod:(LLYHttpMethod)method
                                            urlString:(nullable NSString *)URLString
                                           parameters:(nullable id)parameters
                                             progress:(nullable void (^)(NSProgress * _Nullable downloadProgress))downloadProgress
                                              success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject))success
                                              failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error))failure;


- (nullable NSURLSessionTask *)requestWithMethod:(LLYHttpMethod)method
                                        fileType:(LLYHttpFileType)fileType
                              urlString:(nullable NSString *)URLString
                             parameters:(nullable id)parameters
                               progress:(nullable void (^)(NSProgress * _Nullable downloadProgress))downloadProgress
                                success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject))success
                                failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error))failure
;

- (nullable NSURLSessionDownloadTask *)downloadWithUrl:(nullable NSString *)urlString
                                     progress:(nullable void (^)(NSProgress * _Nullable downloadProgress))downloadProgressBlock
                                  destination:(nullable NSURL * _Nullable(^)(NSURL * _Nullable targetPath, NSURLResponse * _Nullable response))destination
                            completionHandler:(nullable void (^)(NSURLResponse * _Nullable response, NSURL * _Nullable filePath, NSError * _Nullable error))completionHandler;

@end
