[![Build Status](https://travis-ci.org/DALove1025/directory_monitor.svg?branch=master)](https://travis-ci.org/DALove1025/directory_monitor)
[![Maintainability](https://api.codeclimate.com/v1/badges/a99a88d28ad37a79dbf6/maintainability)](https://codeclimate.com/github/DALove1025/directory_monitor/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/a99a88d28ad37a79dbf6/test_coverage)](https://codeclimate.com/github/DALove1025/directory_monitor/test_coverage)

# DirectoryMonitor

The DirectoryMonitor is a very simple utility class used to watch for file
modifications in a directory tree. In addition to the DirectoryMonitor class,
this gem also includes an executable, `watch`, which is a command line wrapper
for invoking the `DirectoryMonitor#on_change` method and executing a shell-
command whenever changes are detected.

## Installation

Add this line to your application's Gemfile:

    gem 'directory_monitor'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install directory_monitor

## Usage of Watch

To use the `watch` executable, type `watch --help` for a short description of
the command-line options supported. There are few additional hints, here.

TODO: Add hits and examples here.

My personal favorite usage of this utility is as a very simple continuous test
monitor. I usually have my project's Rakefile setup with the default task to
execute the test suites for my project. Once done, I'll open a command window
(sometimes on my desktop and other times just a pane in tumx) and run the
following command:

    watch --force --delay=0.5 --suffix='\.rb' "clear; rake 2>&1 | more"

This command will cause the rake file to run once, at startup, and from that
point on, check every half second for updates to my ruby source files. This
is occasionally so helpful I'll actually add this command to my Rakefile
as a task named "autotest".

## Usage of DirectoryMonitor Class

About the best usage example of the class is provided by the `watch` executable
script. See bin/watch for the details.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
