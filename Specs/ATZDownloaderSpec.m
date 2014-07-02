//
//  ATZDownloaderSpec.m
//  Alcatraz
//
//  Created by Marin Usalj on 2/12/14.
//  Copyright 2014 supermar.in. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "ATZDownloader.h"


SPEC_BEGIN(ATZDownloaderSpec)

describe(@"ATZDownloader", ^{

    __block ATZDownloader *downloader;
    
    beforeEach(^{
        downloader = [ATZDownloader new];
    });
    
    it(@"makes the NSData from downloaded tmp/ location", ^{
        NSData *fakeData = [@"hello" dataUsingEncoding:NSUTF8StringEncoding];
        NSURL *tmpURL = [NSURL URLWithString:[NSTemporaryDirectory() stringByAppendingString:@"deleteme"]];
        
        __block NSData *retrievedData = nil;
        [fakeData writeToURL:tmpURL atomically:YES];
        
        [downloader downloadFileFromPath:@"fake_path" progress:^(CGFloat progress) {}
                              completion:^(NSData *data, NSError *error) {
            retrievedData = data;
        }];

        // fucking non TDD code.
//        [downloader URLSession:nil downloadTask:<#(NSURLSessionDownloadTask *)#> didFinishDownloadingToURL:<#(NSURL *)#>]
        
        
    });
});

SPEC_END
