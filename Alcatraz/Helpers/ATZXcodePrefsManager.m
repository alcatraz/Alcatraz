//
//  ATZXcodePrefsManager.m
//  Alcatraz
//
//  Created by Guillaume Algis on 14/07/2015.
//  Copyright (c) 2015 supermar.in. All rights reserved.
//

#import "ATZXcodePrefsManager.h"
#import "ATZPackage.h"
#import "ATZInstaller.h"

static NSString *const NON_APPLE_PLUGINS_KEY_FORMAT = @"DVTPlugInManagerNonApplePlugIns-Xcode-%@";
static NSString *const NON_APPLE_PLUGINS_WHITELISTED_KEY = @"allowed";
static NSString *const NON_APPLE_PLUGINS_BLACKLISTED_KEY = @"skipped";

@implementation ATZXcodePrefsManager

#pragma mark - Singleton

+ (instancetype)sharedManager {
    static ATZXcodePrefsManager *instance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark - Public

- (void)whitelistPackage:(ATZPackage *)package completion:(void(^)(NSError *error))completion {
    NSString *pluginManagerKey = [self xcodeDefaultsNonApplePluginsKey];
    NSMutableDictionary *nonApplePlugins = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:pluginManagerKey] mutableCopy];
    NSMutableDictionary *whitelistedPlugins = [nonApplePlugins[NON_APPLE_PLUGINS_WHITELISTED_KEY] mutableCopy];
    NSMutableDictionary *blacklistedPlugins = [nonApplePlugins[NON_APPLE_PLUGINS_BLACKLISTED_KEY] mutableCopy];

    NSBundle *pluginBundle = [NSBundle bundleWithPath:[package.installer pathForInstalledPackage:package]];
    NSString *pluginIdentifier = [pluginBundle bundleIdentifier];

    NSDictionary *pluginEntry = blacklistedPlugins[pluginIdentifier];
    [blacklistedPlugins removeObjectForKey:pluginIdentifier];
    whitelistedPlugins[pluginIdentifier] = pluginEntry;

    nonApplePlugins[NON_APPLE_PLUGINS_WHITELISTED_KEY] = [whitelistedPlugins copy];
    nonApplePlugins[NON_APPLE_PLUGINS_BLACKLISTED_KEY] = [blacklistedPlugins copy];

    [[NSUserDefaults standardUserDefaults] setObject:[nonApplePlugins copy] forKey:pluginManagerKey];
    BOOL synchronizedSuccessfully = [[NSUserDefaults standardUserDefaults] synchronize];

    NSError *error;
    if (!synchronizedSuccessfully) {
        error = [NSError errorWithDomain:@"Could not update Xcode's preferences and whitelist plugin" code:666 userInfo:nil];
    }

    completion(error);
}

- (BOOL)isPackageBlacklisted:(ATZPackage *)package {
    if (![package isInstalled]) {
        return NO;
    }

    NSString *pluginManagerKey = [self xcodeDefaultsNonApplePluginsKey];
    NSDictionary *nonApplePlugins = [[NSUserDefaults standardUserDefaults] dictionaryForKey:pluginManagerKey];
    NSArray *skippedPluginsIdentifiers = [nonApplePlugins[NON_APPLE_PLUGINS_BLACKLISTED_KEY] allKeys];

    NSBundle *pluginBundle = [NSBundle bundleWithPath:[package.installer pathForInstalledPackage:package]];

    return [skippedPluginsIdentifiers containsObject:[pluginBundle bundleIdentifier]];
}

#pragma mark - Private

- (NSString *)xcodeDefaultsNonApplePluginsKey {
    NSString *xcodeVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    return [NSString stringWithFormat:NON_APPLE_PLUGINS_KEY_FORMAT, xcodeVersion];
}

@end
