You can use these three scripts to image a new microSD card with a pre-configured image that's almost* ready to deploy.

#### Prerequisites
- Running Ubuntu 20.04 or newer.
- Install wget, unzip, lopsetup, whois, git, tree.
- You have an existing ssh key.
- Your ssh key is configured with Github, and has access to the minimeet repo.

### Instructions
1. Configure the constants at the beginning of each of the three scripts.
1. Run ./download-img.sh if you don't already have the latest image file downloaded and unzipped.
1. Run ./prep-img.sh and answer the interactive questions.
1. Insert an SD card into your computer.
1. Run ./write-img.sh.
1. Put the SD card into your raspberry pi and give it 1-2 minutes.
1. SSH using `ssh pi@<hostname>.lan` from a computer on the same network.
1. Run `chmod +x startup.sh && sudo ./startup.sh`.