![Alcatraz](http://alcatraz.io/images/header@2x.png)

Alcatraz is an open-source package manager for Xcode 5. It lets you discover and install plugins, templates and color schemes without the need for manually cloning or copying files. It installs itself as a part of Xcode and it feels like home.

[![Stories in Ready](https://badge.waffle.io/supermarin/Alcatraz.png?label=ready)](https://waffle.io/supermarin/Alcatraz)
[![Build Status](https://travis-ci.org/supermarin/Alcatraz.png?branch=master)](https://travis-ci.org/supermarin/Alcatraz)
[![Alcatraz chat](https://badges.gitter.im/supermarin/alcatraz.png)](https://gitter.im/supermarin/alcatraz)
![Package Manager UI](http://alcatraz.io/images/screenshot@2x.png)

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

![Window Menu Item](http://alcatraz.io/images/menu@2x.png)

## I want to submit my package!

Fork the [Alcatraz package repository](https://github.com/supermarin/alcatraz-packages) and include your package with `name`, `description`, `URL`, and optional `screenshot`. Don't forget to submit a pull request. Further instructions are included in the package repository documentation.

## Development

Alcatraz has a few [contribution guidelines](https://github.com/supermarin/Alcatraz/blob/master/CONTRIBUTING.md), for anyone looking to make it more awesome.

## Uninstall

The installation process creates `~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins/Alcatraz.xcplugin`, which can be deleted to uninstall the plugin completely. To remove all packages installed via Alcatraz, run `rm -rf ~/Library/Application\ Support/Alcatraz/`.

## Team

[Marin Usalj](http://supermar.in) ([@supermarin](https://github.com/supermarin))<br>
[Delisa Mason](http://delisa.me) ([@kattrali](https://github.com/kattrali))<br>
Jurre Stender ([@jurre](https://github.com/jurre))<br>
