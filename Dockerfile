FROM ubuntu

# To initate the build, run
# `docker build -t "pimeet" .`
# from the command line.

WORKDIR /root/build
  
RUN  apt-get update \
  && apt-get install -y wget unzip whois git tree sudo openssh-client \
  && rm -rf /var/lib/apt/lists/*

ADD ./build /root/build
ADD ./scripts /root/scripts

CMD   ssh-keygen && \
      ./download-img.sh && \
      ./prep-img.sh
