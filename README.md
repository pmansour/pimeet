# pimeet
This project shows how you can use a Raspberry Pi 4 to turn any room into a cheap, portable conference room with a touchless experience that can be used for hybrid meetings. In the current limited testing, we had a smooth, lag-free experience.

## TL;DR
We've configured a RP4 to autologin, start Chromium as a dedicated Google account and automatically join the first meeting on its calendar. We hooked this up to a TV, camera and mic/speaker in a meeting room, and invited it to all recurring Google Meet meetings that take place in this room.

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
   The Jabra Speak 510 (*$109* on [Amazon](https://www.amazon.com/dp/B00AQUO5RI))
   should also work fine.

1. **32GB microSD card** (*~$8*)

   The RP4 uses a microSD card as its primary storage, from which it will also boot. While
   booting from an SSD connected via USB 3.0 might be faster, it's much more expensive and
   complicated, and might even require a powered USB hub if it draws too much power. Since
   the microSD card produced smooth quality, it's good enough here.

   microSD cards are currently incredibly cheap - you can get a 32GB SanDisk Ultra
   for $8.49 on [Amazon](https://www.amazon.com/dp/B073JWXGNT/). Don't pay too much attention
   to the speed class - the overall "bus" speed of the RP4's SD card slot is approximately
   23MB/s ([source](https://www.raspberrypi.org/forums/viewtopic.php?t=232148#p1421279)),
   which is much lower than the theoretical read/write speeds that many newer cards boast. 


### Meeting platform

#### Google Meet
We've successfully tested this setup with [Google Meet](https://meet.google.com/)
on the Chromium browser for Raspbian. The audio and video were smooth and lag-free,
and the layout automatically shifted to include attendees and presentation material.

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

## Set up

### Prepare image

TODO: automate these steps in `prepare-image.sh`.

1. Download the latest Raspberry Pi OS (with Desktop and recommended software) from
   [here](https://www.raspberrypi.org/software/operating-systems/#raspberry-pi-os-32-bit).
1. Use Etcher or `dd` to flash this image onto the microSD card.
1. Add a [config.txt](https://www.raspberrypi.org/documentation/configuration/config-txt/README.md) file with the following settings:
   - WiFi: add an entry with your network's SSID and password
   - SSH: add an entry to enable ssh

### Physical setup

TODO: expand on this.
1. Insert in the case.
1. Attach heat sinks.
1. Attach fan.
1. Connect power and HDMI.

### Prepare system

Once your microSD card is ready, eject it from your computer and insert it into the RP4, then
power on the device. The first time you login, you'll need to do some system-wide setup:

TODO: automate these steps in `system-init.sh`

1. Change the password for the default `pi` user.
1. Update the system, packages and distro.
1. Install prerequisites.
   - `jq`
   - 
1. Enable GPU/hardware accelaration in the firmware.
1. Create a new privileged power user with a secure password.
   - Grant all powers to this user.
   - Use `ssh-keygen` and `ssh-copy-id` to configure passwordless-ssh.
1. Delete pi user to avoid forgotten defaults.
1. Create a new unprivileged user, `default`.
   - Should not be able to `sudo` or do any other privileged operation.
1. Configure the boot options passwordless autologin with the new unprivileged user.
   - Should boot into a graphical desktop.
   - Should use passwordless autologin as `default`. 
1. Configure ssh security
   - Disallow ssh password login.
   - Disallow ssh for the root user.
   - Only allow ssh for the privileged power user above.
1. Configure `/usr/share/alsa/alsa.conf` to set the default speaker/mic.
1. Configure automatic security updates through `unattended-upgrades`.

### Prepare default user profile

Once the previous steps are done, reboot the system and connect to the desktop
using the default user (through VNC or a directly hooking up to HDMI/mouse/keyboard).

TODO: automate these steps in `user-init.sh`

1. Enable GPU/hardware accelaration in Chromium.
1. Login to Chromium as this device's dedicated Google account.
1. Install the minimeet extension from the Chrome store.
1. Add an autostart entry for Chromium in full-screen mode.
1. Reboot

That's it! Every time you start your RP4, it should automatically join the next meeting
on its calendar.

## Advanced Topics

### Power button
The RP4 doesn't come with a simple way to physically but safely turn it off. While the CanaKit
package comes with a small power button, this just cuts off power to the device suddenly, which
can result in data corruption if done often.

It's possible to connect a small button to the RP4's GPIO ports which just runs a script to
safely shut down the device.

TODO: add instructions for this.

### HDMI-CEC
While it's possible to keep the RP4 off most of the time and just turn it on before starting
the meeting, this is not ideal for a few reasons:
- It adds an additional step that attendees must remember to do at the start and end
  of every meeting.
- It doesn't give the RP4 time to update itself while it's not being used.
- It doesn't allow you to ssh into the RP4 when you need to perform maintenance.

The RP4 comes with a HDMI-CEC enabled HDMI port. We can configure the RP4 to listen on this
channel to see when the connected TV gets turned on/off, and just start/kill the browser
whenever this happens. That lets you keep the RP4 on long-term, and lets meeting attendees
control everything using the TV remote.

TODO: complete the `hdmi-cec.sh` script and add instructions here.
