# Alcatraz
The Xcode Package Manager!

Alcatraz is an open-source package manager for Xcode. It lets you discover and install plugins, templates and color schemes without the need for manually cloning or copying files. It installs itself as a part of Xcode and it feels like home.

![Package Manager UI](http://mneorr.github.com/Alcatraz/images/plugin.png)

## Installation

Open up your terminal, and paste this:

```
mkdir -p ~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins;
curl -L http://goo.gl/xfmmt | tar xv -C ~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins -
```

or download the repository from Github and build it in Xcode. You'll need to restart Xcode after the installation.

## Usage

Select `Package Manager` from the `Window` menu, then check or uncheck packages to install or remove them. You'll need to restart Xcode after installing plugins or templates.

![Window Menu Item](http://mneorr.github.io/Alcatraz/images/menu.png)

## I want to submit my package!

Fork and edit the [Alcatraz package repository](https://github.com/mneorr/alcatraz-packages) to include your package `name`, `description`, and `URL` in the plugins, color schemes, or templates section, and submit a pull request.

Package definition format:

```
{
  "name": "My Life-Changing Xcode Plugin",
  "url": "https://github.com/me/xcode-life-changing-plugin",
  "description": "Makes Xcode stop, collaborate and listen."
}
```

## Development

Alcatraz is in early alpha, and you should forgive him for any inconvenience.

Public Trello board can be found [here](https://trello.com/b/ZODgq5Av).


## Contributors

Special thanks for Delisa Mason ([@kattrali](https://github.com/kattrali))

Icon by [Derek Briggs](http://derekbriggs.com)
