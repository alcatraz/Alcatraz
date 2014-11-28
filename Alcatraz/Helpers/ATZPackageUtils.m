#import "ATZPackageUtils.h"

#import "Alcatraz.h"
#import "ATZConstants.h"
#import "ATZDownloader.h"
#import "ATZPackage.h"
#import "ATZPackageFactory.h"
#import "ATZPBXProjParser.h"
#import "ATZUtils.h"

static NSArray *__allPackages;

@interface ATZPackageUtils () <NSUserNotificationCenterDelegate>
@end

@implementation ATZPackageUtils

#pragma mark -
#pragma mark Private Methods

+ (ATZPackageUtils *)shared
{
  static ATZPackageUtils *shared;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    shared = [[ATZPackageUtils alloc] init];
  });
  return shared;
}

#pragma mark -
#pragma mark Public Getters

+ (NSArray *)allPackages
{
  return __allPackages;
}

#pragma mark -
#pragma mark Public Methods

+ (void)reloadPackages
{
  ATZDownloader *downloader = [ATZDownloader new];
  [downloader downloadPackageListWithCompletion:^(NSDictionary *packageList, NSError *error) {
    if (error) {
      NSLog(@"[Alcatraz][ATZPackageUtils] Error while downloading packages! %@", error);
    } else {
      __allPackages = [ATZPackageFactory createPackagesFromDicts:packageList];
      [[NSNotificationCenter defaultCenter] postNotificationName:kATZListOfPackagesWasUpdatedNotification object:nil];

      [self updatePackages:__allPackages];
    }
  }];
}

#pragma mark -
#pragma mark Methods to update packages

+ (void)updatePackages:(NSArray *)packages
{
  for (ATZPackage *package in packages) {
    if ([package isInstalled]) {
      [self enqueuePackageUpdate:package];
    }
  }
}

+ (void)enqueuePackageUpdate:(ATZPackage *)package
{
  if (!package.isInstalled) {
    return;
  }

  NSOperation *updateOperation = [NSBlockOperation blockOperationWithBlock:^{
    [package updateWithProgress:^(NSString *progressMessage, CGFloat progress){}
                     completion:^(NSError *failure) {
      if (failure) {
        NSLog(@"[Alcatraz][ATZPackageUtils] Error while updating package %@! %@", package.name, failure);
        return;
      }

      [[NSNotificationCenter defaultCenter] postNotificationName:kATZPackageWasUpdatedNotification object:package];
      [self postUserNotificationForUpdatedPackage:package];
    }];
  }];
  if ([[NSOperationQueue mainQueue] operations].lastObject) {
    [updateOperation addDependency:[[NSOperationQueue mainQueue] operations].lastObject];
  }
  [[NSOperationQueue mainQueue] addOperation:updateOperation];
}

#pragma mark -
#pragma mark User Notification Methods

+ (void)_becomeUserNotificationCenterDelegate
{
  [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:[self shared]];
}

+ (void)postUserNotificationForInstalledPackage:(ATZPackage *)package
{
  [self _becomeUserNotificationCenterDelegate];

  NSUserNotification *notification = [NSUserNotification new];
  notification.title = [NSString stringWithFormat:@"%@ installed", package.type];
  NSString *restartText = package.requiresRestart ? @" Please restart Xcode to use it." : @"";
  notification.informativeText = [NSString stringWithFormat:@"%@ was installed successfully!\n%@", package.name, restartText];

  [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

+ (void)postUserNotificationForUpdatedPackage:(ATZPackage *)package
{
  [self _becomeUserNotificationCenterDelegate];

  NSUserNotification *notification = [NSUserNotification new];
  notification.title = [NSString stringWithFormat:@"%@ updated", package.type];
  NSString *restartText = package.requiresRestart ? @"Please restart Xcode to use it." : @"";
  notification.informativeText = [NSString stringWithFormat:@"%@ was successfully updated!\n%@", package.name, restartText];

  [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
  [[Alcatraz sharedPlugin] checkForCMDLineToolsAndOpenWindow];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
  return YES;
}

@end
