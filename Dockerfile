FROM alpine:3.16

# install tools
RUN apk add --no-cache \
  wget curl sudo vim file tzdata

# タイムゾーン設定
ARG ARG_TZ="Asia/Tokyo"
RUN ln -snf /usr/share/zoneinfo/$ARG_TZ /etc/localtime && \
  echo $ARG_TZ > /etc/timezone

# setup xorg base
# xorg 設定については alpine wiki 参照
# cf. https://wiki.alpinelinux.org/wiki/Alpine_setup_scripts#setup-xorg-base
# setup-xorg-base は最後に rc-service でサービス起動しようとし失敗する為、強制的に正常終了とする( `|| true` の部分)
RUN apk add --no-cache alpine-conf && \
  setup-xorg-base || true

# x + rdp
# xfce については、alpine wiki 参照
# cf. https://wiki.alpinelinux.org/wiki/Xfce
RUN apk add --no-cache \
  xfce4 \
  xfce4-terminal \
  xfce4-screensaver \
  lightdm-gtk-greeter \
  dbus \
  openssl \
  xrdp \
  xorgxrdp

# xrdp 設定
COPY ./etc/X11/Xwrapper.config /etc/X11/
COPY ./etc/xrdp/sesman.ini /etc/xrdp/
COPY ./etc/xrdp/xrdp.ini /etc/xrdp/
RUN mkdir -p /var/log/xrdp
RUN xrdp-keygen xrdp auto

# docker run 設定
RUN apk add --no-cache supervisor 
COPY ./etc/supervisord.conf /etc/
ADD ./etc/supervisor.d/* /etc/supervisor.d/
RUN mkdir -p /var/log/supervisor/

# ユーザ設定
ARG ARG_USER="user"
ARG ARG_PASSWORD="user"
RUN adduser --shell /bin/ash -S $ARG_USER && \
  echo "$ARG_USER ALL=(ALL) ALL" >> /etc/sudoers && \
  echo "$ARG_USER:$ARG_PASSWORD" | chpasswd

# RDP port
EXPOSE 3389

CMD ["bash", "-c", "/usr/bin/supervisord -c /etc/supervisord.conf"]
