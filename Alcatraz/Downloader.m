//
//  Downloader.m
//  Alcatraz
//
//  Created by Marin Usalj on 4/18/13.
//  Copyright (c) 2013 mneorr.com. All rights reserved.
//

#import "Downloader.h"

static NSString *const PLUGINS_REPO_PATH = @"https://gist.github.com/mneorr/2af03afe633279f97afa/raw/66cb7c352be32266b594469ca40592bbe408ac2d/packages.json";

@implementation Downloader

- (void)downloadPackageListAnd:(void (^)(NSDictionary *))completion failure:(void (^)(NSError *))failure {

    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:PLUGINS_REPO_PATH]]
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *receivedData, NSError *error) {
        if (error)
            failure(error);
        else
            completion([NSJSONSerialization JSONObjectWithData:receivedData ?: [NSData data] options:0 error:nil][@"packages"]);
            
    }];
}

@end
