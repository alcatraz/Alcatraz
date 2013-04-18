//
//  Downloader.m
//  Alcatraz
//
//  Created by Marin Usalj on 4/18/13.
//  Copyright (c) 2013 mneorr.com. All rights reserved.
//

#import "Downloader.h"

@implementation Downloader

- (void)downloadPackageListAnd:(void (^)(NSDictionary *))completion failure:(void (^)(NSError *))failure {
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:[self.bundle pathForResource:@"packages" ofType:@"json"]];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    
    completion(json[@"packages"]);
}

@end
