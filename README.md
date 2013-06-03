# Alcatraz
The Xcode Package Manager!

Alcatraz is an open-source package manager for Xcode 4. It lets you discover and install plugins, templates and color schemes without the need for manually cloning or copying files. It installs itself as a part of Xcode and it feels like home.

[![Build Status](https://travis-ci.org/mneorr/Alcatraz.png?branch=master)](https://travis-ci.org/mneorr/Alcatraz)
![Package Manager UI](http://mneorr.github.io/Alcatraz/images/plugin.png)

## Installation

To install, open up your terminal and paste this:

``` bash
mkdir -p ~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins;
curl -L http://goo.gl/xfmmt | tar xv -C ~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins -
```
or download the repository from Github and build it in Xcode. You'll need to restart Xcode after the installation.

Alcatraz requires Xcode Command Line Tools, which can be installed in Xcode via `Preferences > Downloads`.

## Usage

Select `Package Manager` from the `Window` menu, then check or uncheck packages to install or remove them. You'll need to restart Xcode after installing plugins or templates. Installed plugins are checked and updated each time Alcatraz is launched.

![Window Menu Item](http://mneorr.github.io/Alcatraz/images/menu.png)

## I want to submit my package!

Fork the [Alcatraz package repository](https://github.com/mneorr/alcatraz-packages) and include your package with `name`, `description`, `URL`, and optional `screenshot`. Don't forget to submit a pull request. Further instructions are included in the package repository documentation.

## Development

Alcatraz is in early alpha, and you should forgive him for any inconvenience.

Public Trello board can be found [here](https://trello.com/b/ZODgq5Av).

Alcatraz has a few [contribution guidelines](https://github.com/mneorr/Alcatraz/blob/master/CONTRIBUTING.md), for anyone looking to make it more awesome.

## Uninstall

The installation process creates `~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins/Alcatraz.xcplugin`, which can be deleted to uninstall the plugin completely. To remove all packages installed via Alcatraz, run `rm -rf ~/Library/Application\ Support/Alcatraz/`.

## Contributors

Special thanks for Delisa Mason ([@kattrali](https://github.com/kattrali))

Icon by [Derek Briggs](http://derekbriggs.com)


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/mneorr/Alcatraz/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

