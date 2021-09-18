FROM balenalib/raspberry-pi-debian:latest
RUN sudo apt-get update && sudo apt-get install wget tar

RUN wget -qO- https://golang.org/dl/go1.16.5.linux-armv6l.tar.gz | \
    sudo tar xzf - -C /usr/local

# TODO: build picontroller-creds from source.

CMD [""]