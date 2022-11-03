
#import "MTDownloadManager.h"

#import <CommonCrypto/CommonDigest.h>


NSString * const MTDownloadCacheFolderName = @"MTDownloadCache";

static NSString * cacheFolder() {
    NSFileManager *filemgr = [NSFileManager defaultManager];
    static NSString *cacheFolder;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!cacheFolder) {
            NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES).firstObject;
            cacheFolder = [cacheDir stringByAppendingPathComponent:MTDownloadCacheFolderName];
        }
        NSError *error = nil;
        if(![filemgr createDirectoryAtPath:cacheFolder withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"Failed to create cache directory at %@", cacheFolder);
            cacheFolder = nil;
        }
    });
    return cacheFolder;
}

static NSString * LocalReceiptsPath() {
    return [cacheFolder() stringByAppendingPathComponent:@"receipts.data"];
}

static unsigned long long fileSizeForPath(NSString *path) {

    signed long long fileSize = 0;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        if (!error && fileDict) {
            fileSize = [fileDict fileSize];
        }
    }
    return fileSize;
}

static NSString * getMD5String(NSString *str) {

    if (str == nil) return nil;

    const char *cstring = str.UTF8String;
    unsigned char bytes[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cstring, (CC_LONG)strlen(cstring), bytes);

    NSMutableString *md5String = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [md5String appendFormat:@"%02x", bytes[i]];
    }
    return md5String;
}



@interface MTDownloadReceipt ()

@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, copy) NSString *filename;
@property (nonatomic, copy) NSString *truename;
@property (nonatomic, copy) NSString *speed;  // KB/s
@property (nonatomic, assign) MTDownloadState state;


@property (assign, nonatomic) long long totalBytesWritten;
@property (assign, nonatomic) long long totalBytesExpectedToWrite;
@property (nonatomic, copy) NSProgress *progress;

@property (strong, nonatomic) NSOutputStream *stream;

@property (nonatomic, assign) NSUInteger totalRead;
@property (nonatomic, strong) NSDate *date;



@end
@implementation MTDownloadReceipt

- (NSOutputStream *)stream
{
    if (_stream == nil) {
        _stream = [NSOutputStream outputStreamToFileAtPath:self.filePath append:YES];
    }
    return _stream;
}

- (NSString *)filePath {

    NSString *path = [cacheFolder() stringByAppendingPathComponent:self.filename];
    if (![path isEqualToString:_filePath] ) {
        if (_filePath && ![[NSFileManager defaultManager] fileExistsAtPath:_filePath]) {
            NSString *dir = [_filePath stringByDeletingLastPathComponent];
            [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        _filePath = path;
    }

    return _filePath;
}


- (NSString *)filename {
    if (_filename == nil) {
        NSString *pathExtension = self.url.pathExtension;
        if (pathExtension.length) {
            _filename = [NSString stringWithFormat:@"%@.%@", getMD5String(self.url), pathExtension];
        } else {
            _filename = getMD5String(self.url);
        }
    }
    return _filename;
}

- (NSString *)truename {
    if (_truename == nil) {
        _truename = self.url.lastPathComponent;
    }
    return _truename;
}

- (NSProgress *)progress {
    if (_progress == nil) {
        _progress = [[NSProgress alloc] initWithParent:nil userInfo:nil];
    }
    @try {
        _progress.totalUnitCount = self.totalBytesExpectedToWrite;
        _progress.completedUnitCount = self.totalBytesWritten;
    } @catch (NSException *exception) {

    }
    return _progress;
}

- (long long)totalBytesWritten {

    return fileSizeForPath(self.filePath);
}


- (instancetype)initWithURL:(NSString *)url {
    if (self = [self init]) {

        self.url = url;
        self.totalBytesExpectedToWrite = 1;
    }
    return self;
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.url forKey:NSStringFromSelector(@selector(url))];
    [aCoder encodeObject:self.filePath forKey:NSStringFromSelector(@selector(filePath))];
    [aCoder encodeObject:@(self.state) forKey:NSStringFromSelector(@selector(state))];
    [aCoder encodeObject:self.filename forKey:NSStringFromSelector(@selector(filename))];
    [aCoder encodeObject:@(self.totalBytesWritten) forKey:NSStringFromSelector(@selector(totalBytesWritten))];
    [aCoder encodeObject:@(self.totalBytesExpectedToWrite) forKey:NSStringFromSelector(@selector(totalBytesExpectedToWrite))];
    // --new
    [aCoder encodeObject:self.headerJSONStr forKey:NSStringFromSelector(@selector(headerJSONStr))];
    [aCoder encodeObject:@(self.lastState) forKey:NSStringFromSelector(@selector(lastState))];
    [aCoder encodeObject:@(self.initBytes) forKey:NSStringFromSelector(@selector(initBytes))];

}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.url = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(url))];
        self.filePath = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(filePath))];
        self.state = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(state))] unsignedIntegerValue];
        self.filename = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(filename))];
        self.totalBytesWritten = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(totalBytesWritten))] unsignedIntegerValue];
        self.totalBytesExpectedToWrite = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(totalBytesExpectedToWrite))] unsignedIntegerValue];
        // --new
        self.headerJSONStr = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(headerJSONStr))];
        self.lastState = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(lastState))] unsignedIntegerValue];
        self.initBytes = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(initBytes))] unsignedIntegerValue];
    }
    return self;
}


@end


#pragma mark -

#if OS_OBJECT_USE_OBJC
#define MCDispatchQueueSetterSementics strong
#else
#define MCDispatchQueueSetterSementics assign
#endif

@interface MTDownloadManager () <NSURLSessionDataDelegate>
@property (nonatomic, MCDispatchQueueSetterSementics) dispatch_queue_t synchronizationQueue;
@property (strong, nonatomic) NSURLSession *session;

@property (nonatomic, assign) NSInteger maximumActiveDownloads;
@property (nonatomic, assign) NSInteger activeRequestCount;

@property (nonatomic, strong) NSMutableArray *queuedTasks;
@property (nonatomic, strong) NSMutableDictionary *tasks;

@property (nonatomic, strong) NSMutableDictionary *allDownloadReceipts;
@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundTaskId;
@end

@implementation MTDownloadManager

+ (NSURLSessionConfiguration *)defaultURLSessionConfiguration {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];

    configuration.HTTPShouldSetCookies = YES;
    configuration.HTTPShouldUsePipelining = NO;
    configuration.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
    configuration.allowsCellularAccess = YES;
    configuration.timeoutIntervalForRequest = 60.0;
    configuration.HTTPMaximumConnectionsPerHost = 10;
    configuration.discretionary = YES;
    return configuration;
}


- (instancetype)init {


    NSURLSessionConfiguration *defaultConfiguration = [self.class defaultURLSessionConfiguration];

    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:defaultConfiguration delegate:self delegateQueue:queue];

    return [self initWithSession:session
            downloadPrioritization:MTDownloadPrioritizationFIFO
            maximumActiveDownloads:3 ];
}


- (instancetype)initWithSession:(NSURLSession *)session downloadPrioritization:(MTDownloadPrioritization)downloadPrioritization maximumActiveDownloads:(NSInteger)maximumActiveDownloads {
    if (self = [super init]) {

        self.session = session;
        self.downloadPrioritizaton = downloadPrioritization;
        self.maximumActiveDownloads = maximumActiveDownloads;

        self.queuedTasks = [[NSMutableArray alloc] init];
        self.tasks = [[NSMutableDictionary alloc] init];
        self.activeRequestCount = 0;

        NSString *name = [NSString stringWithFormat:@"com.mc.downloadManager.synchronizationqueue-%@", [[NSUUID UUID] UUIDString]];
        self.synchronizationQueue = dispatch_queue_create([name cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_SERIAL);

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }

    return self;
}

+ (instancetype)defaultInstance {
    static MTDownloadManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


- (NSMutableDictionary *)allDownloadReceipts {
    if (_allDownloadReceipts == nil) {
        NSDictionary *receipts = [NSKeyedUnarchiver unarchiveObjectWithFile:LocalReceiptsPath()];
        _allDownloadReceipts = receipts != nil ? receipts.mutableCopy : [NSMutableDictionary dictionary];
    }
    return _allDownloadReceipts;
}

- (void)saveReceipts:(NSDictionary *)receipts {
    [NSKeyedArchiver archiveRootObject:receipts toFile:LocalReceiptsPath()];
}

- (MTDownloadReceipt *)updateReceiptWithURL:(NSString *)url state:(MTDownloadState)state {
    MTDownloadReceipt *receipt = [self downloadReceiptForURL:url];
    receipt.state = state;

    [self saveReceipts:self.allDownloadReceipts];

    return receipt;
}



- (MTDownloadReceipt *)downloadFileWithURL:(NSString * _Nullable)url
        headers:(NSString *)headerJSONStr
        progress:(nullable void (^)(NSProgress *downloadProgress, MTDownloadReceipt *receipt))downloadProgressBlock
        destination:(nullable NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
        success:(nullable void (^)(NSURLRequest *request, NSHTTPURLResponse  * _Nullable response, NSURL *filePath))success
                                   failure:(nullable void (^)(NSURLRequest *request, NSHTTPURLResponse * _Nullable response, NSError *error))failure{


    __block MTDownloadReceipt *receipt = [self downloadReceiptForURL:url];
    receipt.headerJSONStr = headerJSONStr;
    // 同步数据
    [self saveReceipts:self.allDownloadReceipts];
    dispatch_sync(self.synchronizationQueue, ^{
        NSString *URLIdentifier = url;
        if (URLIdentifier == nil) {
            if (failure) {
                NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadURL userInfo:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(nil, nil, error);
                });
            }
            return;
        }
        receipt.successBlock = success;
        receipt.failureBlock = failure;
        receipt.progressBlock = downloadProgressBlock;

        if (receipt.state == MTDownloadStateCompleted && receipt.totalBytesWritten == receipt.totalBytesExpectedToWrite) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (receipt.successBlock) {
//                    receipt.successBlock(nil,nil,[NSURL URLWithString:receipt.url]);
                }
            });
            return;
        }

        if (receipt.state == MTDownloadStateDownloading && receipt.totalBytesWritten != receipt.totalBytesExpectedToWrite) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (receipt.progressBlock) {
                    receipt.progressBlock(receipt.progress,receipt);
                }
            });
            return;
        }

        NSURLSessionDataTask *task = self.tasks[receipt.url];
        // 当请求暂停一段时间后。转态会变化。所有要判断下状态
        if (!task || ((task.state != NSURLSessionTaskStateRunning) && (task.state != NSURLSessionTaskStateSuspended))) {
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:receipt.url]];

            NSString *range = [NSString stringWithFormat:@"bytes=%zd-", receipt.totalBytesWritten];
            [request setValue:range forHTTPHeaderField:@"Range"];
            // 添加headers
            if (headerJSONStr && headerJSONStr.length > 0) {

                NSData *jsonData = [headerJSONStr dataUsingEncoding:NSUTF8StringEncoding];
                NSError *err;
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                     options:NSJSONReadingMutableContainers
                                     error:&err];
                NSLog(@"dic::::%@",dic);
                if(err == nil)
                {
                    for (NSString * key in dic) {
                        NSString * v = dic[key];
                        [request addValue:v forHTTPHeaderField:key];
                    }
                }
                NSLog(@"dic::::%@",request.allHTTPHeaderFields);

            }

            // 开始任务
            NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request];
            task.taskDescription = receipt.url;
            self.tasks[receipt.url] = task;
            [self.queuedTasks addObject:task];
        }

        [self resumeWithDownloadReceipt:receipt];
    });
    return receipt;
}



#pragma mark - -----------------------

- (NSURLSessionDataTask*)safelyRemoveTaskWithURLIdentifier:(NSString *)URLIdentifier {
    __block NSURLSessionDataTask *task = nil;
    dispatch_sync(self.synchronizationQueue, ^{
        task = [self removeTaskWithURLIdentifier:URLIdentifier];
    });
    return task;
}

//This method should only be called from safely within the synchronizationQueue
- (NSURLSessionDataTask *)removeTaskWithURLIdentifier:(NSString *)URLIdentifier {
    NSURLSessionDataTask *task = self.tasks[URLIdentifier];
    [self.tasks removeObjectForKey:URLIdentifier];
    return task;
}

- (void)safelyDecrementActiveTaskCount {
    dispatch_sync(self.synchronizationQueue, ^{
        if (self.activeRequestCount > 0) {
            self.activeRequestCount -= 1;
        }
    });
}

- (void)safelyStartNextTaskIfNecessary {
    dispatch_sync(self.synchronizationQueue, ^{
        if ([self isActiveRequestCountBelowMaximumLimit]) {
            while (self.queuedTasks.count > 0) {
                NSURLSessionDataTask *task = [self dequeueTask];
                MTDownloadReceipt *receipt = [self downloadReceiptForURL:task.taskDescription];
                if (task.state == NSURLSessionTaskStateSuspended && receipt.state == MTDownloadStateWillResume) {
                    [self startTask:task];
                    break;
                }
            }
        }
    });
}


- (void)startTask:(NSURLSessionDataTask *)task {
    [task resume];
    ++self.activeRequestCount;
    [self updateReceiptWithURL:task.taskDescription state:MTDownloadStateDownloading];
}

- (void)enqueueTask:(NSURLSessionDataTask *)task {
    switch (self.downloadPrioritizaton) {
    case MTDownloadPrioritizationFIFO:  //
        [self.queuedTasks addObject:task];
        break;
    case MTDownloadPrioritizationLIFO:  //
        [self.queuedTasks insertObject:task atIndex:0];
        break;
    }
}

- (NSURLSessionDataTask *)dequeueTask {
    NSURLSessionDataTask *task = nil;
    task = [self.queuedTasks firstObject];
    [self.queuedTasks removeObject:task];
    return task;
}

- (BOOL)isActiveRequestCountBelowMaximumLimit {
    return self.activeRequestCount < self.maximumActiveDownloads;
}


#pragma mark -
- (MTDownloadReceipt *)downloadReceiptForURL:(NSString *)url {

    if (url == nil) return nil;
    MTDownloadReceipt *receipt = self.allDownloadReceipts[url];
    if (receipt) return receipt;
    receipt = [[MTDownloadReceipt alloc] initWithURL:url];
    receipt.state = MTDownloadStateNone;
    receipt.totalBytesExpectedToWrite = 1;

    dispatch_sync(self.synchronizationQueue, ^{
        [self.allDownloadReceipts setObject:receipt forKey:url];
        [self saveReceipts:self.allDownloadReceipts];
    });

    return receipt;
}

- (void)updateReceipt:(MTDownloadReceipt *) receipt
        Url: (NSString *)url
        Headers:(NSString *) headerJSONStr{
    dispatch_sync(self.synchronizationQueue, ^{
        [self.allDownloadReceipts removeObjectForKey:receipt.url];
        receipt.url = url;
        receipt.headerJSONStr = headerJSONStr;
        [self.allDownloadReceipts setObject:receipt forKey:receipt.url];
        [self saveReceipts:self.allDownloadReceipts];
    });
}

#pragma mark -  NSNotification
- (void)applicationWillTerminate:(NSNotification *)not {

    [self suspendAll];
}

- (void)applicationDidReceiveMemoryWarning:(NSNotification *)not {

    [self suspendAll];
}

- (void)applicationWillResignActive:(NSNotification *)not {
    /// 捕获到失去激活状态后
    Class UIApplicationClass = NSClassFromString(@"UIApplication");
    BOOL hasApplication = UIApplicationClass && [UIApplicationClass respondsToSelector:@selector(sharedApplication)];
    if (hasApplication ) {
        __weak __typeof__ (self) wself = self;
        UIApplication * app = [UIApplicationClass performSelector:@selector(sharedApplication)];
        self.backgroundTaskId = [app beginBackgroundTaskWithExpirationHandler:^{
                                         __strong __typeof (wself) sself = wself;

                                         if (sself) {
                             [sself suspendAll];

                             [app endBackgroundTask:sself.backgroundTaskId];
                             sself.backgroundTaskId = UIBackgroundTaskInvalid;
                         }
                     }];
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)not {

    Class UIApplicationClass = NSClassFromString(@"UIApplication");
    if(!UIApplicationClass || ![UIApplicationClass respondsToSelector:@selector(sharedApplication)]) {
        return;
    }
    if (self.backgroundTaskId != UIBackgroundTaskInvalid) {
        UIApplication * app = [UIApplication performSelector:@selector(sharedApplication)];
        [app endBackgroundTask:self.backgroundTaskId];
        self.backgroundTaskId = UIBackgroundTaskInvalid;
    }
}

#pragma mark - MTDownloadControlDelegate

- (void)resumeWithURL:(NSString *)url {

    if (url == nil) return;

    MTDownloadReceipt *receipt = [self downloadReceiptForURL:url];
    [self resumeWithDownloadReceipt:receipt];

}
- (void)resumeWithDownloadReceipt:(MTDownloadReceipt *)receipt {

    if ([self isActiveRequestCountBelowMaximumLimit]) {
        NSURLSessionDataTask *task = self.tasks[receipt.url];
        // 当请求暂停一段时间后。转态会变化。所有要判断下状态
        if (!task || ((task.state != NSURLSessionTaskStateRunning) && (task.state != NSURLSessionTaskStateSuspended))) {
            [self downloadFileWithURL:receipt.url headers:receipt.headerJSONStr progress:receipt.progressBlock destination:nil success:receipt.successBlock failure:receipt.failureBlock];
        }else {
            [self startTask:self.tasks[receipt.url]];
            receipt.date = [NSDate date];
        }
    }else {
        receipt.state = MTDownloadStateWillResume;
        [self saveReceipts:self.allDownloadReceipts];
        [self enqueueTask:self.tasks[receipt.url]];
    }
}

- (void)suspendAll {

    for (NSURLSessionDataTask *task in self.queuedTasks) {

        MTDownloadReceipt *receipt = [self downloadReceiptForURL:task.taskDescription];
        receipt.state = MTDownloadStateFailed;
        [task suspend];
        [self safelyDecrementActiveTaskCount];
    }
    [self saveReceipts:self.allDownloadReceipts];

}
-(void)suspendWithURL:(NSString *)url {

    if (url == nil) return;

    MTDownloadReceipt *receipt = [self downloadReceiptForURL:url];
    [self suspendWithDownloadReceipt:receipt];

}
- (void)suspendWithDownloadReceipt:(MTDownloadReceipt *)receipt {

    [self updateReceiptWithURL:receipt.url state:MTDownloadStateSuspened];
    NSURLSessionDataTask *task = self.tasks[receipt.url];
    if (task) {
        [task suspend];
        [self safelyDecrementActiveTaskCount];
        [self safelyStartNextTaskIfNecessary];
        [task cancel];
        receipt.lastState = MTDownloadStateSuspened;
        [self saveReceipts:self.allDownloadReceipts];
    }
}

- (void)removeWithURL:(NSString *)url {

    if (url == nil) return;

    MTDownloadReceipt *receipt = [self downloadReceiptForURL:url];
    [self removeWithDownloadReceipt:receipt];

}
- (void)removeWithDownloadReceipt:(MTDownloadReceipt *)receipt {

    NSURLSessionDataTask *task = self.tasks[receipt.url];
    if (task) {
        [task cancel];
    }

    [self.queuedTasks removeObject:task];
    [self safelyRemoveTaskWithURLIdentifier:receipt.url];

    dispatch_sync(self.synchronizationQueue, ^{
        [self.allDownloadReceipts removeObjectForKey:receipt.url];
        [self saveReceipts:self.allDownloadReceipts];
    });

    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:receipt.filePath error:nil];

}
#pragma mark - <NSURLSessionDataDelegate>
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    MTDownloadReceipt *receipt = [self downloadReceiptForURL:dataTask.taskDescription];
    receipt.totalBytesExpectedToWrite = receipt.totalBytesWritten + dataTask.countOfBytesExpectedToReceive;
    receipt.state = MTDownloadStateDownloading;
    if (receipt.totalBytesWritten == 0) { // 哦 第一次我～～
        receipt.initBytes = dataTask.countOfBytesExpectedToReceive;
    }
    if (receipt.totalBytesWritten <= dataTask.countOfBytesExpectedToReceive) {
        receipt.lastState = MTDownloadStateNone;
    }

    if (receipt.totalBytesExpectedToWrite >= receipt.initBytes && receipt.initBytes != 0) {
        receipt.lastState = MTDownloadStateNone;
    }

    [self saveReceipts:self.allDownloadReceipts];

    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{

    dispatch_sync(self.synchronizationQueue, ^{

        __block NSError *error = nil;
        MTDownloadReceipt *receipt = [self downloadReceiptForURL:dataTask.taskDescription];

        // Speed
        receipt.totalRead += data.length;
        NSDate *currentDate = [NSDate date];
        if ([currentDate timeIntervalSinceDate:receipt.date] >= 1) {
            double time = [currentDate timeIntervalSinceDate:receipt.date];
            long long speed = receipt.totalRead/time;
            receipt.speed = [self formatByteCount:speed];
            receipt.totalRead = 0.0;
            receipt.date = currentDate;
        }

        // Write Data
        NSInputStream *inputStream =  [[NSInputStream alloc] initWithData:data];
        NSOutputStream *outputStream = [[NSOutputStream alloc] initWithURL:[NSURL fileURLWithPath:receipt.filePath] append:YES];
        [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

        [inputStream open];
        [outputStream open];

        while ([inputStream hasBytesAvailable] && [outputStream hasSpaceAvailable]) {
            uint8_t buffer[1024];

            NSInteger bytesRead = [inputStream read:buffer maxLength:1024];
            if (inputStream.streamError || bytesRead < 0) {
                error = inputStream.streamError;
                break;
            }

            NSInteger bytesWritten = [outputStream write:buffer maxLength:(NSUInteger)bytesRead];
            if (outputStream.streamError || bytesWritten < 0) {
                error = outputStream.streamError;
                break;
            }

            if (bytesRead == 0 && bytesWritten == 0) {
                break;
            }
        }
        [outputStream close];
        [inputStream close];

        receipt.progress.totalUnitCount = receipt.totalBytesExpectedToWrite;
        receipt.progress.completedUnitCount = receipt.totalBytesWritten;

        dispatch_async(dispatch_get_main_queue(), ^{
            if (receipt.progressBlock) {
                receipt.progressBlock(receipt.progress,receipt);
            }
        });
    });

}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    MTDownloadReceipt *receipt = [self downloadReceiptForURL:task.taskDescription];

    if (error) {
        receipt.state = MTDownloadStateFailed;
        if (error.code == -1005 || error.code == -1001) {
//            receipt.state = MTDownloadStateSuspened;
            receipt.lastState = MTDownloadStateURLFailed;
        }
        if(error.code == -999) {
            receipt.state = MTDownloadStateSuspened;
            receipt.lastState = MTDownloadStateSuspened;
        }
        [self saveReceipts:self.allDownloadReceipts];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (receipt.failureBlock) {
                receipt.failureBlock(task.originalRequest,(NSHTTPURLResponse *)task.response,error);
            }
        });
    }else {
        unsigned long long localSize = fileSizeForPath(receipt.filePath);
        if (localSize <= 1) {
            receipt.state = MTDownloadStateFailed;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (receipt.failureBlock) {
                    receipt.failureBlock(task.originalRequest,(NSHTTPURLResponse *)task.response,error);
                }
            });
            return;
        }

        if (receipt.lastState == MTDownloadStateSuspened ||
            receipt.lastState == MTDownloadStateURLFailed) {
            [receipt.stream close];
            receipt.stream = nil;
            return;
        }

//        if (localSize >= receipt.totalBytesExpectedToWrite) {
//
//        }

        [receipt.stream close];
        receipt.stream = nil;
        receipt.state = MTDownloadStateCompleted;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (receipt.successBlock) {
                receipt.successBlock(task.originalRequest,(NSHTTPURLResponse *)task.response,task.originalRequest.URL);
            }
            receipt.successBlock = nil;
            [self saveReceipts:self.allDownloadReceipts];
        });
    }

    [self saveReceipts:self.allDownloadReceipts];
    [self safelyDecrementActiveTaskCount];
    [self safelyStartNextTaskIfNecessary];

}

- (NSString*)formatByteCount:(long long)size
{
    return [NSByteCountFormatter stringFromByteCount:size countStyle:NSByteCountFormatterCountStyleFile];
}

+ (NSData*)data_xor:(NSData *)data{
    Byte * sourceDataPoint = (Byte *)[data bytes];
    for (long i = 0; i < data.length; i++) {
        sourceDataPoint[i] = sourceDataPoint[i] ^ 1;
    }
    return data;
}
@end
