You can use these three scripts to image a new microSD card with a pre-configured image that's ready to deploy.

#### Prerequisites
- Running Ubuntu 20.04 or later.
- Install wget, unzip, lopsetup, whois, git, tree.

### Instructions
1. Run ./download-img.sh if you don't already have the latest image file downloaded and unzipped.
1. Run ./prep-img.sh and answer the interactive questions.
1. Insert an SD card into your computer.
1. Run ./write-img.sh.
1. Put the microSD card into your raspberry pi and give it 1-2 minutes.
1. SSH using `ssh pi@<hostname>.lan` from a computer on the same network.
1. Plug the microSD card into a raspberry pi and turn it on.

On the first run, the PiMeet device will update itself and do some last-minute runtime configuration, then reboot itself and enter into service.
