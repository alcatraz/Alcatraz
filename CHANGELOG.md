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

