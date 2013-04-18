//
//  Downloader.h
//  Alcatraz
//
//  Created by Marin Usalj on 4/18/13.
//  Copyright (c) 2013 mneorr.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Downloader : NSObject

@property NSBundle *bundle; // TODO: delete this when networking comes in

- (void)downloadPackageListAnd:(void(^)(NSDictionary *packageList))completion failure:(void(^)(NSError *error))failure;

@end
