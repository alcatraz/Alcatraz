---
layout: page
title: "Writing Plugins"
date: 2014-06-14T00:00:00Z
comments: true
external-url:
categories:
---

## Writing Plugins.

So at this point we all [know][1] [how][2] [to write][3] an Xcode plugin, we have [the headers][4] and even a [plugin template][5]. Still it is not as swift to do as writing an app, that's why this post will give you some advice on best practices and avoiding common pitfalls.

### Use Xcode for debugging

Look at Alcatraz' [own Xcode project file][9] to see how to set your project up to build & run by launching a second instance of Xcode. It will make your life much easier.

### If swizzling, use Aspects

The [Aspects][6] library created by [Peter Steinberger][7] is awesome, as it makes swizzling more succinct and delightful. If you have to swizzle in order to achieve your goal, there is really no reason not to use it.

### Beware of interactions with other plugins

Even though method swizzling is a supported part of the Objective-C runtime, augmenting functionality with it is still kind of hacky. If you use other third-party plugins besides your own, be aware of [problems][8] which can arise due to swizzling the same or related methods.

### Avoid Xcode 3

When you grep through the Xcode headers, you will sometimes end up with hits for the *Xcode3Core* and *Xcode3UI* plugins. It is generally a good idea to avoid them, as most of that functionality is no longer used by modern versions of Xcode. Those plugins are a shim added during the times of Xcode 4, so that they could ship before all the functionality was rewritten, but it is used less and less with each new version.

### Check in your Pods directory

Even though it is normally a subject of extended debate, if you use CocoaPods for your Xcode plugin, definetely check in your *Pods* directory. Alcatraz will only run `xcodebuild` on your project, so if you don't check the *Pods* directory into version control, your project will not build -> sad 🐼.

### Test your plugin after adding it to Alcatraz

After you submitted your pull request to the [packages repository][10], delete your local copy of the plugin and try to download & install it via Alcatraz to make sure it actually works correctly.

### Use DTrace to discover your point of entry

It can sometimes be hard to figure out what the correct point to hook into Xcode is. Read [this post][11] by [Jack Chen][12] to learn how to use DTrace to monitor runtime behaviour of Xcode.

### IDEWorkspaceWindowController

If you try to manipulate Xcode's basic UI, more often than not, the [IDEWorkspaceWindowController][13] is a good place to start your search for the correct API. It also offers a convenient class method `+workspaceWindowControllers` to call functionality on all of them.


[1]: https://www.youtube.com/watch?v=6LcflnBHyXs
[2]: http://vimeo.com/85025185
[3]: http://mdevcon.com/posts/2014/01/09/kendall-helmstetter-gelner/
[4]: https://github.com/luisobo/Xcode-RuntimeHeaders
[5]: https://github.com/kattrali/Xcode5-Plugin-Template
[6]: https://github.com/steipete/Aspects
[7]: http://petersteinberger.com/
[8]: https://github.com/neonichu/BBUDebuggerTuckAway/issues/11
[9]: https://github.com/supermarin/Alcatraz/tree/master/Alcatraz.xcodeproj
[10]: https://github.com/supermarin/alcatraz-packages
[11]: http://chen.do/blog/2013/10/22/reverse-engineering-xcode-with-dtrace/
[12]: https://twitter.com/chendo
[13]: https://github.com/luisobo/Xcode-RuntimeHeaders/blob/master/IDEKit/IDEWorkspaceWindowController.h
