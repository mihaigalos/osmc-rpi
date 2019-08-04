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

# ports and volumes
VOLUME /config/kodi
VOLUME /data
EXPOSE 8080 9777/udp

CMD ["bash", "/root/start.sh"]
