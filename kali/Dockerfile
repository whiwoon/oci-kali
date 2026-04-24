FROM kalilinux/kali-last-release

ENV DEBIAN_FRONTEND=noninteractive

ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN echo "deb http://kali.download/kali kali-last-snapshot main contrib non-free non-free-firmware" > /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        xfce4 \
        xfce4-terminal \
        xrdp \
        xorgxrdp \
        sudo \
        dbus-x11 \
        curl \
        xz-utils \
        fontconfig \
        tzdata && \
    mkdir -p /usr/share/fonts/D2Coding && \
    curl -fLko /tmp/D2Coding.tar.xz https://github.com/ryanoasis/nerd-fonts/releases/latest/download/D2Coding.tar.xz && \
    tar -xf /tmp/D2Coding.tar.xz -C /usr/share/fonts/D2Coding && \
    fc-cache -fv && \
    rm /tmp/D2Coding.tar.xz && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    sed -i '2i unset DBUS_SESSION_BUS_ADDRESS\nunset XDG_RUNTIME_DIR' /etc/xrdp/startwm.sh

ARG KALI_PASSWORD=kali
RUN useradd -m -s /bin/bash kali && \
    echo "kali:${KALI_PASSWORD}" | chpasswd && \
    usermod -aG sudo kali

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
