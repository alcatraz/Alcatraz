#import <Foundation/Foundation.h>

@class ATZPackage;

@interface ATZPackageUtils : NSObject

/*
 * Getters
 */
+ (NSArray *)allPackages;

/*
 * Reloaders
 */
+ (void)reloadPackages;

/*
 * User Notification Methods
 */
+ (void)postUserNotificationForInstalledPackage:(ATZPackage *)package;
+ (void)postUserNotificationForUpdatedPackage:(ATZPackage *)package;

@end
