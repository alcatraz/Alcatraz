## 1.2.1

- Support for Xcode 8.1

## 1.2.0

- Plugins are no longer required to have a .xcodeproj filename matching their `name` in `packages.json` (#471)
- Support GIF image on screenshot preview (#432)
- Support for Xcode 8 (#488, see also #475 on why it might not work for you)

## 1.1.19

- Fix a crash caused by invalid downloaded image data being displayed anyway. #320 #334 #335 #479
  Thanks @piv199 for the help diagnosing the issue.

## 1.1.18

- Fix plugin installation failing if the plugin's name contains `.` dots

## 1.1.17

- Support Xcode 7.3


## 1.1.16

- Display plugins blocked by Xcode with a special orange "blocked" button

## 1.1.6

- Support for Xcode 6.4 beta


## 1.1.5

- Fix plugins with nibs by cleaning before building


## 1.0.6

- Fix summary field naming conflict
- Experimental support for new betas


## 1.0.3

- Support Xcode 5.1


## 1.0.1

- Fixed auto-updating plugins


## 1.0

- Support for Xcode 5


## 0.6.1

#### Bug fixes

- Fixed loading Xcode-related applications, like FileMerge


## 0.6

##### Enhancements

- Less memory usage. Alcatraz reuses the same instance when opened multiple times in an Xcode session
- Show current version in the title bar
- Show a notification after successfully installing a package


## 0.5

##### Features

- Previewing screenshot inside Alcatraz. You don't even have to visit the repository. How awesome is that?
  Thanks @jurre for implementing this feature.


## 0.4.1

##### Bug fixes

- Fixed singleton creation for subclasses.


## 0.4

##### Features

- __Experimental__ added automatic package updates. You don't have to worry about manually updating plugins or templates.

##### Enhancements

- Less memory usage. Installers are singletons


## 0.3

##### Features

- Installing almost any plugin doesn't require Xcode restarting
- Automatic updates. You shouldn't worry about updating Alcatraz anymore :)
- Added support for a different plugin name and install dir. Solves [BBUncrustify](https://github.com/mneorr/alcatraz-packages/pull/17)
- Alcatraz haz got a [twitter account](https://twitter.com/alcatraz_xcode)!

##### Enhancements

- Made a dedicated download / clone directory in ~/Library/Application Support/Alcatraz
- [Code] Installer logic is refactored

##### Note

This is an important update! Please update manually using the install script
``` bash
mkdir -p ~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins;
curl -L http://goo.gl/xfmmt | tar xv -C ~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins -
```

