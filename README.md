# pimeet
This project shows how you can use a Raspberry Pi 4 to turn a TV into a cheap, portable conference room with a touchless experience that can be used for hybrid meetings. In the current limited testing, we had a smooth, lag-free experience.

## TL;DR
We've configured a RP4 to autologin, start Chromium as a dedicated g-suite user and automatically join the first meeting on its calendar. We hooked this up to a TV, camera and mic/speaker in a meeting room, and invited it to all recurring Google Meet meetings that take place in this room.

To start a meeting, just plug the RP4 into power when you arrive. Online attendees will be able to see and hear each other as well as the physical attendees, and the presenter can just share their screen with the meeting from their personal device and have it be seen by all attendees.

## Prerequisites

### Equipment

Here's what you'll need:

1. **Raspberry Pi 4** (*~$85*)

   We recommend the 4GB CanaKit Basic Starter Kit with Fan, available from
   [Amazon](https://www.amazon.com/gp/product/B07VYC6S56) for $82.99.
   The case, heat sinks and fan are needed to keep the RP4 cool enough for
   lag-free video streaming. The 5V 3.5A power supply keeps steady power to
   the CPU/GPU while powering peripherals and WiFi/Bluetooth. The micro-HDMI
   to HDMI cable lets you simply connect to the TV while supporting HDMI-CEC.

1. **TV** (*~$80-200*)

   Any TV with a HDMI input should work, but a TV that supports HDMI-CEC allows
   things like using the TV's power status to join/leave a meeting.

1. **USB Webcam** (*~$50-120*)

   You can get a cheap camera under $50 that will do the job, such as
   [this one](https://www.amazon.com/gp/product/B072MMH33F). However, if you
   have a larger meeting room and want better quality video, then something like
   the Logitech C920 might be desired.

1. **Bluetooth speaker/mic** (*$50-200*)

   Strictly speaking, this doesn't need to support bluetooth, and it doesn't need
   to be a single device with a speaker/mic combo. However, a bluetooth device
   allows you to place the mics closer to where the attendees are sitting for better
   audio. A combined mic/speaker will often include some built-in noise cancellation
   to avoid echo.

   We tested with the Jabra Speak 710 (*$230* on
   [Amazon](https://www.amazon.com/gp/product/B071R7NGTD)) and got great results.
   The Jabra Speak 510 (*$109* on [Amazon](https://www.amazon.com/dp/B00AQUO5RI)) should also
   work fine.

### Meeting platform

#### Google Meet
We've successfully tested this setup with [Google Meet](https://meet.google.com/)
on the Chromium browser for Raspbian. The audio and video were smooth and lag-free,
and the layout 

Google Meet also had some nice integrations that made this possible, such as
a simple landing page that shows the next meeting, as well as integration with
the Google account used for Chromium. This allowed a simple Chrome extension to
automatically find and join the next meeting on browser startup.

#### Zoom
We've also investigated the possibility of Zoom integration, but couldn't get this
working. While Zoom has a Linux client, it doesn't run on ARM (needed for the RP4).
We also tried Zoom's web client on Chromium but it just kept freezing and never
properly joined the meeting.

#### Others?
We haven't tested other platforms, but if you've got one working, please feel free
to send a PR!
