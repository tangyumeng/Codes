//
//  DDServerLogger.m
//  LogSampleProject
//
//  Created by tangyumeng on 2017/5/14.
//  Copyright © 2017年 DiDiMap. All rights reserved.
//

#import "DDServerLogger.h"
#import "AFHTTPSessionManager.h"

#import "AFHTTPSessionManager.h"


@interface DDServerLogger()

@property (nonatomic,strong) NSMutableArray *logMessagesArray;

@property (nonatomic,strong) AFHTTPSessionManager *sessionManager;

@end

@implementation DDServerLogger
- (instancetype)init {
    self = [super init];
    if (self) {
        self.deleteInterval = 0;
        self.maxAge = 0;
        self.deleteOnEverySave = NO;
        self.saveInterval = 60;
        self.saveThreshold = 5;
        
        //别忘了在 dealloc 里 removeObserver
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(saveOnSuspend)
                                                     name:@"UIApplicationWillResignActiveNotification"
                                                   object:nil];
    }
    return self;
}

- (void)saveOnSuspend {
    dispatch_async(_loggerQueue, ^{
        [self db_save];
    });
}




- (void)db_save {
    //判断是否在 logger 自己的GCD队列中
    if (![self isOnInternalLoggerQueue])
        NSAssert(NO, @"db_saveAndDelete should only be executed on the internalLoggerQueue thread, if you're seeing this, your doing it wrong.");
    
    //如果缓存内没数据，啥也不做
    if ([_logMessagesArray count] == 0)
        return;
    
//    获取缓存中所有数据，之后将缓存清空
    NSArray *oldLogMessagesArray = [_logMessagesArray copy];
    _logMessagesArray = [NSMutableArray arrayWithCapacity:0];
    
    //用换行符，把所有的数据拼成一个大字符串
    NSString *logMessagesString = [oldLogMessagesArray componentsJoinedByString:@"\n"];
    
    //发送给咱自己服务器(自己实现了)
    [self post:logMessagesString];
}

- (void)db_delete {
    
}

- (void)db_saveAndDelete {
    
}

- (BOOL)db_log:(DDLogMessage *)logMessage
{
    if (!_logFormatter) {
        //没有指定 formatter
        return NO;
    }
    
    if (!_logMessagesArray)
        _logMessagesArray = [NSMutableArray arrayWithCapacity:500]; // 我们的saveThreshold只有500，所以一般情况下够了
    
    if ([_logMessagesArray count] > 2000) {
        // 如果段时间内进入大量log，并且迟迟发不到服务器上，我们可以判断哪里出了问题，在这之后的 log 暂时不处理了。
        // 但我们依然要告诉 DDLog 这个存进去了。
        return YES;
    }
    
    //利用 formatter 得到消息字符串，添加到缓存
    [_logMessagesArray addObject:[_logFormatter formatLogMessage:logMessage]];
    return YES;
}

-(AFHTTPSessionManager *)sessionManager
{
    if (!_sessionManager) {
        _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://127.0.0.1:8080"]];
        [_sessionManager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    }
    
    return _sessionManager;
}


-(void)post:(NSString *)logmessage
{
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.1.115:8080/api/logger"]];
    req.HTTPMethod = @"POST";
    req.timeoutInterval=15.0f;
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    NSDictionary *requestBody = @{@"content":logmessage};
    NSData *dictData = [NSJSONSerialization dataWithJSONObject:requestBody options:kNilOptions error:NULL];
    [req setHTTPBody:dictData];
    
    [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (!error) {
            NSLog(@"Reply JSON: %@", responseObject);
            
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                //blah blah
            }
        } else {
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
        }
    }] resume];
}
@end
