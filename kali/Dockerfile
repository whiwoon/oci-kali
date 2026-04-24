FROM kalilinux/kali-rolling:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN echo "deb http://kali.download/kali kali-rolling main contrib non-free non-free-firmware" > /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        xfce4 \
        xfce4-terminal \
        xrdp \
        sudo \
        dbus-x11 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ARG KALI_PASSWORD=kali
RUN useradd -m -s /bin/bash kali && \
    echo "kali:${KALI_PASSWORD}" | chpasswd && \
    usermod -aG sudo kali

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
