# Alcatraz
The Xcode Package Manager!

Alcatraz is an open-source package manager for Xcode. It lets you discover and install packages, without the need for manually cloning or copying files. It is installed as a part of Xcode, and it feels like home.

## Installation

Download the repository from Github and build it in Xcode. You'll need to restart Xcode after the installation.

## Usage

Check or uncheck packages to install or remove them. You'll need to restart Xcode after installing plugins or templates.

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