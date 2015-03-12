//
//  ATZAnalytics.m
//  Alcatraz
//
//  Created by Marin Usalj on 3/11/15.
//  Copyright (c) 2015 supermar.in. All rights reserved.
//

#import "ATZAnalytics.h"
#import "ATZVersion.h"
#import "KeenClient.h"

static NSString *const KEEN_PROJECT_ID = @"547fb4b0d2eaaa337a6c0f9a";
static NSString *const KEEN_WRITE_KEY = @"a36b908fd88f4df72872e531b5fae840ccd454e488baa65cf16c1a090d323e102fb268b4e02da9b2243dcbf1785ac25d610368c120c0dc04ef12a1eb269fc5cfdf2b73ef078d638cdc679027a07b8b75dd77293f5c2da15fe72322fa369769ef478723dff96ff51c5113fef7761392e5";
static NSString *const KEEN_READ_KEY = @"15755058e1ff49ea6a812101e37ea15e86792b267a10a85afb1979231303a4f914438bafa5cc2caa74f081253bc509f03e0b25c9c5bbd83bf4ac85233e7ddb372907293bfe5710e385a16affdaf963f72a7a31b544c7f875b2f56f6aa1684d0437f5fca66f7cc045cd10be88f7697265";

static NSString *const ATZEventCollectionAlcatraz = @"alcatraz";

@implementation ATZAnalytics

void ATZLogEvent(NSString *event) {
    ATZLogEventWithDictionary(event, @{});
}

void ATZLogEventWithDictionary(NSString *name, NSDictionary *event) {
    NSMutableDictionary *nameDictionary = @{@"event": name}.mutableCopy;
    [nameDictionary setValuesForKeysWithDictionary:event];
    ATZLogEventWithCollection(ATZEventCollectionAlcatraz, nameDictionary);
}

void ATZLogEventWithCollection(NSString *collection, NSDictionary *event) {
    NSError *error = nil;
    [[KeenClient sharedClient] addEvent:event toEventCollection:ATZEventCollectionAlcatraz error:&error];
    if (error) {
        NSLog(@"Error tracking event! %@", error);
    }
    [[KeenClient sharedClient] uploadWithFinishedBlock:^{
        NSLog(@"Events uploaded to keen!");
    }];
}

+ (void)initialize
{
    if (self == [ATZAnalytics class]) {
        [KeenClient disableGeoLocation];
        [KeenClient sharedClientWithProjectId:KEEN_PROJECT_ID andWriteKey:KEEN_WRITE_KEY andReadKey:KEEN_READ_KEY];
        [KeenClient sharedClient].globalPropertiesDictionary = @{
            @"alcatraz_version": @(ATZ_VERSION)
        };
        [KeenClient enableLogging];
        ATZLogEvent(@"xcode_launch");
    }
}

@end
