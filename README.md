![Alcatraz](http://alcatraz.io/images/header@2x.png)

Alcatraz is an open-source package manager for Xcode 5+. It lets you discover and install plugins, templates and color schemes without the need for manually cloning or copying files. It installs itself as a part of Xcode and it feels like home.

[![Stories in Ready](https://badge.waffle.io/supermarin/Alcatraz.png?label=ready)](https://waffle.io/supermarin/Alcatraz)
[![Build Status](https://travis-ci.org/supermarin/Alcatraz.svg?branch=master)](https://travis-ci.org/supermarin/Alcatraz)
[![Alcatraz chat](https://badges.gitter.im/supermarin/alcatraz.png)](https://gitter.im/supermarin/alcatraz)
![Package Manager UI](http://alcatraz.io/images/screenshot@2x.png)

## Installation

To install, open up your terminal and paste this:

``` bash
curl -fsSL https://raw.github.com/supermarin/Alcatraz/master/Scripts/install.sh | sh
```
or download the repository from Github and build it in Xcode. You'll need to restart Xcode after the installation.

Alcatraz requires Xcode Command Line Tools, which can be installed in Xcode via `Preferences > Downloads`.

## Requirements

Alcatraz for Xcode only supports OS X 10.9+.

## Usage

Select `Package Manager` from the `Window` menu, then check or uncheck packages to install or remove them. You'll need to restart Xcode after installing plugins or templates. Installed plugins are checked and updated each time Alcatraz is launched.

<img src="http://alcatraz.io/images/menu@2x.png" width="411px"/>

## I want to submit my package!

Fork the [Alcatraz package repository](https://github.com/supermarin/alcatraz-packages) and include your package with `name`, `description`, `URL`, and optional `screenshot`. Don't forget to submit a pull request. Further instructions are included in the package repository documentation.

## Development

Alcatraz has a few [contribution guidelines](https://github.com/supermarin/Alcatraz/blob/master/CONTRIBUTING.md), for anyone looking to make it more awesome.

## Troubleshooting

If "nothing" happens when installing packages, try the following self-help steps:

1. Verify which copy (if more than one are installed) of git is being run (`which git`).
2. Make sure you're running a recent version of git (`git --version`).
3. If you've used Xcode developer preview releases in the past, make certain Xcode isn't stuck using an inappropriate developer path by resetting it (`sudo xcode-select --reset`).

## Uninstall

Open up your terminal and paste this: 

```bash
rm -rf ~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins/Alcatraz.xcplugin
```

To remove all packages installed via Alcatraz, run `rm -rf ~/Library/Application\ Support/Alcatraz/`.

## Team

[Marin Usalj](http://supermar.in) ([@supermarin](https://github.com/supermarin))<br>
[Delisa Mason](http://delisa.me) ([@kattrali](https://github.com/kattrali))<br>
Jurre Stender ([@jurre](https://github.com/jurre))<br>
