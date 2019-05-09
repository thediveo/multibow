# (Why) This Project Is Archived

I've spent a lot of effort on developing advanced functionality for
Pibow/Multibow, such as asynchronous key handling, key sequence chaining,
timers, multiple overlays, unit tests for all this stuff, et cetera.

The advanced asynchronous functionality requires changes in the base Pibow
firmware. Pimoroni initially provided a low-level function timer tick on a
separate code branch (without a release), on which I then built a lot of
advanced functionality.

However, many months later, and after several fruitless attempts to get some
reaction from Pimoroni, there is no visible activity to release the low-level
timer tick function I need for Multibow as part of the ordinary Pibow firmware
releases.

Since I don't have the resources to maintain my own fork of the Pibow software
and are a believing in the principle of "upstream first", this is the end of
my Multibow project.

For reference: [Pibow Issue #15: Timer
Support?](https://github.com/pimoroni/keybow-firmware/issues/15)