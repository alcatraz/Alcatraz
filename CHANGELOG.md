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

