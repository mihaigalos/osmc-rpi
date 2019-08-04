ARG OSMC_VERSION=20190623
FROM mihaigalos/osmc-rpi:base_${OSMC_VERSION}

# Enable systemd
ENV INITSYSTEM on

# Configure Kodi group
RUN usermod -a -G audio root && \
usermod -a -G video root && \
usermod -a -G lp root && \
usermod -a -G dialout root && \
usermod -a -G cdrom root && \
usermod -a -G disk root && \
usermod -a -G adm root

# Kodi directories
RUN  mkdir -p /config/kodi >/dev/null 2>&1 || true && rm -rf /home/osmc/.kodi && ln -s /config/kodi /home/osmc/.kodi \
    && mkdir -p /data >/dev/null 2>&1
#RUN  mkdir -p /config/kodi >/dev/null 2>&1 || true && rm -rf /root/.kodi && ln -s /config/kodi /root/.kodi \
#    && mkdir -p /data >/dev/null 2>&1

RUN  chown osmc:osmc /data && chown osmc:osmc /home/osmc/.kodi && chown osmc:osmc /config/kodi
RUN echo "/usr/lib/kodi/kodi.bin --standalone -fs --lircdev /var/run/lirc/lircd" >/root/start.sh

#----------------------------------------------------------------------------------------------------------------
ARG USER_NAME="osmc"
ARG USER_PASSWORD="osmc"

ENV USER_NAME $USER_NAME
ENV USER_PASSWORD $USER_PASSWORD


RUN apt-get update && \
  apt-get install -y sudo \
  curl \
  git-core \
  zsh \
  wget \
  nano \
  npm \
  fonts-powerline \
  # set up locale
  && locale-gen en_US.UTF-8 \
  # add a user (--disabled-password: the user won't be able to use the account until the password is set)
  && adduser --quiet --disabled-password --shell /bin/zsh --home /home/$USER_NAME --gecos "User" $USER_NAME \
  # update the password
  && echo "${USER_NAME}:${USER_PASSWORD}" | chpasswd && usermod -aG sudo $USER_NAME


  # the user we're applying this too (otherwise it most likely install for root)
  USER $USER_NAME
  # terminal colors with xterm
  ENV TERM xterm

  # run the installation script
  RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true
#----------------------------------------------------------------------------------------------------------------

# ports and volumes
VOLUME /config/kodi
VOLUME /data
EXPOSE 8080 9777/udp

CMD ["bash", "/root/start.sh"]
