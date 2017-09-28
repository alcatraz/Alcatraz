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
@property (strong, nonatomic) NSMutableDictionary<NSNumber *, NSDictionary *> *callbacks;
@property (strong, nonatomic) NSMutableDictionary<NSNumber *, NSNumber *> *reponsesExpectedDataLength;
@property (strong, nonatomic) NSMutableDictionary<NSNumber *, NSMutableData *> *responsesData;
@property (strong, nonatomic) NSURLSession *urlSession;
@end


@implementation ATZDownloader

static NSString *const ATZ_DEFAULT_REPO_PATH = @"https://raw.github.com/alcatraz/alcatraz-packages/master/packages.json";
static NSString *const ATZ_REPO_KEY = @"ATZRepoPath";
static NSString *const PROGRESS = @"progress";
static NSString *const COMPLETION = @"completion";

- (id)init {
    self = [super init];
    if (!self) return nil;

    _callbacks = [NSMutableDictionary new];
    _reponsesExpectedDataLength = [NSMutableDictionary new];
    _responsesData = [NSMutableDictionary new];

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
    NSURLSessionDataTask *task = [[self urlSession] dataTaskWithRequest:request];

    NSMutableDictionary* callbacks = [[NSMutableDictionary alloc] initWithCapacity:2];
    if (completion)
        callbacks[COMPLETION] = completion;
    if (progress)
        callbacks[PROGRESS] = progress;

    self.callbacks[@(task.taskIdentifier)] = callbacks;

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

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    
    long long expectedContentLength = response.expectedContentLength;
    if (expectedContentLength != NSURLResponseUnknownLength) {
        self.reponsesExpectedDataLength[@(dataTask.taskIdentifier)] = @(response.expectedContentLength);
    }
    
    self.responsesData[@(dataTask.taskIdentifier)] = [NSMutableData new];
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    
    NSMutableData *partialData = self.responsesData[@(dataTask.taskIdentifier)];
    [partialData appendData:data];
    
    NSNumber *reponsesExpectedDataLength = self.reponsesExpectedDataLength[@(dataTask.taskIdentifier)];
    ATZDownloadProgress progressBlock =  self.callbacks[@(dataTask.taskIdentifier)][PROGRESS];
    if (progressBlock && reponsesExpectedDataLength) {
        CGFloat progress = partialData.length / [reponsesExpectedDataLength doubleValue];
        
        // response.expectedContentLength might have returned a smaller number of bytes than the actual data length
        progress = fmax(progress, 1.0);
        
        progressBlock(progress);
    }
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler {
    
    completionHandler(request);
}


#pragma mark - NSURLSessionTask delegate

/* Sent as the last message related to a specific task.  Error may be
 * nil, which implies that no error occurred and this task is complete.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    ATZDataDownloadCompletion completionBlock = self.callbacks[@(task.taskIdentifier)][COMPLETION];
    if (completionBlock) {
        if (error) {
            // Client error
            completionBlock(nil, error);
        }
        else {
            NSData *data = self.responsesData[@(task.taskIdentifier)];
            NSHTTPURLResponse *httpResponse;
            if ([task.response isKindOfClass:[NSHTTPURLResponse class]]) {
                httpResponse = (NSHTTPURLResponse *)task.response;
            }

            if (httpResponse && httpResponse.statusCode != 200) {
                NSString *description = [NSString stringWithFormat:@"Download task failed with status code %ld : %@", httpResponse.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode]];
                NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: description };
                error = [NSError errorWithDomain:ATZDownloaderErrorDomain code:ATZDownloaderInvalidHTTPStatusCode userInfo:userInfo];
                completionBlock(nil, error);
            }
            else if (!data) {
                NSString *description = [NSString stringWithFormat:@"Download task returned empty content (%@)", task.originalRequest.URL.absoluteString];
                NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: description };
                error = [NSError errorWithDomain:ATZDownloaderErrorDomain code:ATZDownloaderEmptyContent userInfo:userInfo];
                completionBlock(nil, error);
            }
            else {
                completionBlock(data, nil);
            }
        }
    }
    
    [self cleanupDataRelatedToTask:task];
}


#pragma mark - Private

- (NSURLSession *)urlSession {
    if (_urlSession) return _urlSession;

    _urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                delegate:self
                                           delegateQueue:[NSOperationQueue mainQueue]];
    return _urlSession;
}

- (void)cleanupDataRelatedToTask:(NSURLSessionTask *)task
{
    NSNumber *taskIdentifier = @(task.taskIdentifier);
    [self.callbacks removeObjectForKey:taskIdentifier];
    [self.reponsesExpectedDataLength removeObjectForKey:taskIdentifier];
    [self.responsesData removeObjectForKey:taskIdentifier];
}

@end
