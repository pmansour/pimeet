You can use these three scripts to image a new microSD card with a pre-configured image that's ready to deploy.

#### Prerequisites
- Running Ubuntu 20.04 or later[^1].
- Install wget, unzip, lopsetup, whois, git, tree.

[^1]: Other Linux distros might work too, but the scripts were only tested on this OS. WSL was problematic last I tried it (in ~late 2020).

### Instructions
1. Run [`./download-img.sh`](./download-img.sh) if you don't already have the latest image file downloaded and unzipped.
1. Run [`./prep-img.sh`](./prep-img.sh) and answer the interactive questions.
1. Insert an SD card into your computer.
1. Run [`./write-img.sh`](./write-img.sh) to flash the microSD card.
1. Insert the microSD card into your raspberry pi and turn it on.

On the first boot, the PiMeet device will update itself and do some dynamic runtime configuration, then reboot itself and enter into service. If you have a TV connected via HDMI, you can watch these steps in real-time. Otherwise, just wait 5-10 minutes until the system restarts.
