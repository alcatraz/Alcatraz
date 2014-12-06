// Downloader.m
//
// Copyright (c) 2013 Marin Usalj | supermar.in
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import "ATZDownloader.h"

@interface ATZDownloader()
@property (strong, nonatomic) NSMutableDictionary *callbacks;
@property (strong, nonatomic) NSURLSession *urlSession;
@end


@implementation ATZDownloader

static NSString *const ATZ_DEFAULT_REPO_PATH = @"https://raw.github.com/supermarin/alcatraz-packages/master/packages.json";
static NSString *const ATZ_REPO_KEY = @"ATZRepoPath";
static NSString *const PROGRESS = @"progress";
static NSString *const COMPLETION = @"completion";

- (id)init {
    self = [super init];
    if (!self) return nil;
    
    _callbacks = [NSMutableDictionary new];
    
    return self;
}

- (void)downloadPackageListWithCompletion:(ATZJSONDownloadCompletion)completion {
    [self downloadFileFromPath:[ATZDownloader packageRepoPath]
                      progress:^(CGFloat progress) {}
                    completion:^(NSData *data, NSError *error) {
                        
        if (error) { completion(nil, error); return; }

        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        completion(JSON[@"packages"], error);
    }];
}

- (void)downloadFileFromPath:(NSString *)remotePath progress:(ATZDownloadProgress)progress
                                                  completion:(ATZDataDownloadCompletion)completion {

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:remotePath]];
    NSURLSessionTask *task = [[self urlSession] downloadTaskWithRequest:request];

    NSMutableDictionary* callbacks = [[NSMutableDictionary alloc] initWithCapacity:2];
    if (completion)
        callbacks[COMPLETION] = completion;
    if (progress)
        callbacks[PROGRESS] = progress;

    self.callbacks[task] = callbacks;
    
    [task resume];
}

#pragma mark - Package Repo

+ (NSString*)packageRepoPath {
    NSString* path = [[NSUserDefaults standardUserDefaults] valueForKey:ATZ_REPO_KEY];
    if (!path)
        path = ATZ_DEFAULT_REPO_PATH;

    return path;
}

+ (void)resetPackageRepoPath {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:ATZ_REPO_KEY];
}

+ (void)setPackagesRepoPath:(NSString*)path {
    [[NSUserDefaults standardUserDefaults] setObject:path forKey:ATZ_REPO_KEY];
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
                              didFinishDownloadingToURL:(NSURL *)location {

    ATZDataDownloadCompletion completionBlock = self.callbacks[downloadTask][COMPLETION];
    if (completionBlock)
        completionBlock([NSData dataWithContentsOfURL:location], nil);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
                                           didWriteData:(int64_t)bytesWritten
                                      totalBytesWritten:(int64_t)totalBytesWritten
                              totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {

    CGFloat progress = (CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite;

    ATZDownloadProgress progressBlock =  self.callbacks[downloadTask][PROGRESS];
    if (progressBlock)
        progressBlock(progress);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler {
    completionHandler(request);
}


#pragma mark - NSURLSessionTask delegate

/* Sent as the last message related to a specific task.  Error may be
 * nil, which implies that no error occurred and this task is complete.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    
}


#pragma mark - Private

- (NSURLSession *)urlSession {
    if (_urlSession) return _urlSession;
    
    _urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                delegate:self
                                           delegateQueue:[NSOperationQueue mainQueue]];
    return _urlSession;
}





@end
