objective-c-subscript
=====================

Use the new Objective-C subscript notation for arrays and dictionaries right now.

The new subscript notation is normally only available when building applications for OS X 10.8, but using these categories you can use them in with older versions of the MacOS X SDK and when building your iOS apps.

I made these while developing an iOS app and thought it would be nice to share them.

How to use
----------

Copy the files into your project, and import the categories you need or import Subscript.h to import all four.

All functions work according to the official documentation available on Apple's developer site.

If you are using ARC, you only need the header files, the compiler will insert all the methods for you.

How it works
------------

If your project doesn't use ARC, the compiler won't insert the builtin version of these functions, so you need to provide your own implementation.

If your project uses ARC (as advised by Apple), the compiler will insert these four functions for you.

I found out about this when I compiled a small test program for Base SDK OS X 10.8, deployment target set to 10.7. No definition for the functions exists there, but the program worked perfectly on OS X 10.7. Puzzled a used builtin tools to list all functions and there they were. Their named includes 'ARCLite', and after some experimenting it turned out compiling with ARC and only definitions of these functions will make the compiler insert these small precompiled functions.

Requirements
------------

You need Xcode 4.4 to use these files.

Examples
--------

```objective-c
#import "Subscript.h"
```

```objective-c
NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
userInfo[@"email"] = @"foo@example.com";
[Mailer sendMailTo:userInfo[@"email"]];
```


```objective-c
NSMutableArray* emailAddresses = [NSMutableArray arrayWithArray:@[@"baz@example.com"]];
emailAddresses[0] = @"foo@example.com";
emailAddresses[1] = @"bar@example.com";
[Mailer sendMailToMultiple:emailAddresses];
```