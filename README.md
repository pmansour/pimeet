# pimeet
This project uses a Raspberry Pi 4 to turn any room into a cheap conference room that can automatically join meetings on its calendar.

## Background
### Hybrid meetings
The COVID-19 pandemic that started in 2020 took many organizations and businesses by surprise, forcing many to move to a work-from-home model and turn in-person meetings into digital ones. Many small organizations without dedicated IT organizations, such as churches, also had to scramble to use an online solution (e.g. Zoom, Google Meet, Microsoft Teams) for their regular meetings.

As society has gone back-and-forth between different waves of the pandemic, one thing became clear: **hybrid meetings are here to stay**. Even as many organizations return to in-person meetings, there is still a sizable chunk of the volunteer and workforce that will remain remote. The reasons for this are no longer limited to just COVID-19 precautions; they now also include convenience, physical relocation, and many other reasons.

### Cost of existing devices
There are some existing devices on the market for turning regular rooms with a TV into “meeting rooms”. Unfortunately, such devices are expensive enough to be infeasible for most small businesses and nonprofits. For example, Logitech has [a suite](https://www.logitech.com/en-us/products/video-conferencing/room-solutions/google-meet.html) of Google Meet video conferencing hardware, but prices start at around $1,500-$2,000 **per room**. For a small organization looking to configure 6-12 meeting rooms (e.g. for each Sunday School class at a church), the cost of this hardware alone (without wiring or installation) can easily approach $20,000, which is often well above the available budgets.

### Why not a laptop?
A common way to solve the hybrid meeting problem is to have someone bring over a laptop, connect it to a TV through a HDMI cable, join the meeting from there and share their screen. Not only is this approach limited (weak laptop microphone and camera, echo), but it’s also ad-hoc and hard to repeat consistently since it requires some level of technical proficiency to get everything set up and troubleshoot common issues. It also has several failure modes, such as missing or incorrect cables, spotty connections, different instructions for Windows/Mac/Linux and so on.

While this can work in some cases where the presenter knows what they’re doing and is prepared, it creates a lot of friction for individuals without a ton of technical proficiency. It also makes for a difficult “IT support” journey due to the inconsistent hardware used.

## Design goals
This solution was designed to solve the above issues. Specifically, we aim to create a solution that is:

- Easy to deploy to several rooms within an organization.
- Cheap (ideally <$100 per room, excluding the TV and webcam).
- Automated / easy to use.
- Easy to maintain over time.

## PiMeet
### Overview
To solve the above issues, we've built a system that uses a combination of cheap hardware and custom software to turn any room into a meeting room. This system has been tested extensively and has been through several iterations to produce the current fleet, which has been powering the Sunday School classes at St George Coptic Orthodox Church in Kirkland, WA since fall of 2021.

The current name for this device is PiMeet.

### User Experience
One of the goals is to make this dead-simple to use, and hard to get wrong. As such, the UX is incredibly simple:
- When someone enters a room, they turn on the PiMeet device and wait for it to join the next meeting on its calendar.
- When they’re done, they hit the power button again to turn it off.
- *That’s it!*

See these [Quickstart instructions](https://docs.google.com/document/d/11bFKDRnKby4PvWUyqYbBlXx3mhg-zHjduksk8KyJA5A/view), which were printed, laminated and hung in the rooms at St George Coptic Orthodox Church, Kirkland.

<p align="center">
<img src="/docs/room-demo.png" alt="Room configured with PiMeet" />
<br />
<strong>Figure A</strong>: A meeting room configured with PiMeet. Note the raspberry pi mounted directly under the TV.
</p>

Each PiMeet device has its own Google account[^1] with its own calendar, and the device will just join the next meeting on its calendar. Anybody within the organization can schedule a Google Meet[^2] meeting and invite the room’s account to it, and when they turn on the PiMeet it will just automagically join that new meeting.

[^1]: For example, `mezzanine-room@{your-domain}.org`
[^2]: The system already has experimental Zoom support (through Zoom Web), but the performance of Zoom Web is not very responsive when content is being presented. This will hopefully get better over time.

PiMeet achieves those goals by configuring a Raspberry PI 4B to be a 1-click meeting room device. In a nutshell, each device runs [Raspberry PI OS](https://www.raspberrypi.com/software/) (a Debian Linux fork), specially configured to run Chromium on startup with the [Minimeet extension](https://github.com/pmansour/minimeet). This extension logs into its configured Google account and joins the next available meeting on its calendar.

<p align="center">
![Creating a meeting using Google Calendar](/docs/create-meeting.png)
<br />
<strong>Figure B</strong>: Inviting a room's account (<code>grade3-room@{your-domain}.org</code>) to a new meeting. This works for ad-hoc as well as recurring (e.g. weekly or daily) meetings.
</p>

### Hardware components
As of today, a typical deployment consists of the following hardware:
- **Raspberry Pi 4B 4GB**. This model costs $55 MSRP[^3] (see [official resellers](https://www.raspberrypi.com/products/raspberry-pi-4-model-b#find-reseller)), and has powerful-enough specs[^4] to produce smooth, lag-free meetings consistently.
- **Raspberry Pi accessories**. This includes a 32GB microSD card, a HDMI-to-HDMI cable, and a USB-C power supply. Overall, these should cost <$20 per device.
- **ArgonOne V.2 case**. This case costs $25 on [Amazon](https://www.amazon.com/dp/B07WP8WC3V), and has excellent cooling, ports, form-factor as well as a physical safe-shutdown power button and an IR sensor that allows use of a remote control.
- **Logitech C920x Webcam**. This webcam costs $60 on [Amazon](https://www.amazon.com/dp/B085TFF7M1), and produces smooth 1080p video while also including a dual-microphone. In most small rooms, this mic is good enough that no external audio solution is needed.

In addition to these basics, some optional additions may make for a better UX in some rooms:
- **JabraSpeak 510 bluetooth speaker**. This wireless speaker/microphone combo costs $115 on [Amazon](https://www.amazon.com/dp/B00C3XW5L4). It produces great echo-free audio and has reliable wireless connectivity through the provided dongle.
- **Sparkfun IR remote**. This little remote-control costs $4.50 at [Sparkfun](https://www.sparkfun.com/products/14865). It allows for operating the PiMeet device wirelessly without having to press the physical on button.
- **Cheap bluetooth mouse**. You can buy a pack of 10 for $45 (~$4.50 each) on [Amazon](https://www.amazon.com/gp/product/B087CR8RD1). Having a dedicated mouse in each room not only allows for troubleshooting as necessary, but enables some advanced room controls such as explicitly admitting people into each meeting.

[^3]: Due to the current supply-chain crisis, it may be hard to procure these at MSRP in large quantities right now. However, stock is constantly being replenished, so hopefully soon this will not be an issue in a few months.
[^4]: Quad-core CPU, 4GB RAM, USB-3 controller and ports, 2x [micro-]HDMI ports with HDMI-CEC.

### Software components
The PiMeet system consists of a 64-bit Raspberry Pi OS image, with several customizations and configurations to enable smooth video conferencing, various credentials (WiFi networks, fleet admin account, room-specific meeting account), some systemd services and autostart applications to enable complete automation, as well as a copy of the [Minimeet Chrome extension](https://github.com/pmansour/minimeet). The latter is an extension that automates the process of logging in to Google Meet and joining a meeting hands-free.

The process of imaging a new microSD card and configuring its credentials is automated through the three [build scripts](build/) in the PiMeet GitHub repository. Imaging a new device only takes a few minutes and requires no specialized knowledge other than the ability to execute bash scripts.

## Set up
Installing this system in a room involves a few steps:
1. Mount a TV in a good location.
1. Assemble a new raspberry pi in the ArgonOne V2 case, write a new image onto a microSD card and insert it. Now you have a PiMeet device.
1. Attach the PiMeet device to the bottom of the TV using these command stickers. See the pictures in the Quickstart guide above for inspiration.
1. Attach the webcam either on top of the TV, or at the bottom (using more command stickers).
1. Connect the webcam, HDMI and power cables to the PiMeet device, and use cable fasteners and sleeves to hide the complexity.
1. Turn on the power.

## Feedback
If you have questions, feedback or suggestions, you're welcome to file issues on GitHub or send an email to `pimeet-help@googlegroups.com`.
