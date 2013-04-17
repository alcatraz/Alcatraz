//
//  Package.h
//  Alcatraz
//
//  Created by Marin Usalj on 4/17/13.
//  Copyright (c) 2013 mneorr.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Package :NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *description;
@property (strong, nonatomic) NSURL *url;

@property (nonatomic) BOOL isInstalled;

@end
