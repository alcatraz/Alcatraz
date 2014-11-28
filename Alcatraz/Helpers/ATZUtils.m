#import "ATZUtils.h"

#import "ATZConstants.h"

NSString *ATZPluginsDataDirectoryPath()
{
  return [NSHomeDirectory() stringByAppendingPathComponent:kATZPluginsDataDirectory];
}

NSString *ATZPluginsInstallPath()
{
  return [NSHomeDirectory() stringByAppendingPathComponent:kATZPluginsInstallDirectory];
}
