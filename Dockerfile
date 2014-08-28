# tigervnc-lxde desktop
#

FROM  ubuntu:14.04
MAINTAINER akyshr "akyshr@gmail.com"

# Set the env variable DEBIAN_FRONTEND to noninteractive
ENV DEBIAN_FRONTEND noninteractive

# make sure the package repository is up to date
RUN apt-get update

# install sshd
RUN apt-get install -y openssh-server

# Installing the apps.
RUN apt-get install -y firefox

RUN apt-get install -y xserver-xorg fonts-takao-gothic fonts-takao-mincho fonts-takao-pgothic

# Fake a fuse install
RUN apt-get install libfuse2
RUN cd /tmp ; apt-get download fuse
RUN cd /tmp ; dpkg-deb -x fuse_* .
RUN cd /tmp ; dpkg-deb -e fuse_*
RUN cd /tmp ; rm fuse_*.deb
RUN cd /tmp ; echo -en '#!/bin/bash\nexit 0\n' > DEBIAN/postinst
RUN cd /tmp ; dpkg-deb -b . /fuse.deb
RUN cd /tmp ; dpkg -i /fuse.deb
RUN rm -fr /tmp ; mkdir /tmp ; chmod 5777 /tmp

# Set locale (fix the locale warnings)
RUN localedef -v -c -i en_US -f UTF-8 en_US.UTF-8 || :
RUN localedef -v -c -i ja_JP -f UTF-8 ja_JP.UTF-8 || :

RUN apt-get install -y xdm

RUN sudo apt-get -y install python-software-properties software-properties-common
RUN sudo apt-add-repository ppa:ubuntu-mate-dev/ppa
RUN sudo apt-add-repository ppa:ubuntu-mate-dev/trusty-mate
RUN sudo apt-get update
RUN sudo apt-get -y install --no-install-recommends ubuntu-mate-core ubuntu-mate-desktop
RUN apt-get install -y scim-anthy

# Copy the files into the container
ADD . /src
RUN rm /src/*~

# install tigervnc
RUN dpkg -i /src/packages/*.deb
RUN chown -R root.root /src

#setup ssh
RUN mkdir /var/run/sshd

RUN echo ":0 local /usr/bin/Xtigervnc :0 -geometry 1280x768 -depth 24 -desktop vnc -SecurityTypes None -nolisten tcp" > /etc/X11/xdm/Xservers

RUN cp -r /src/config/* /etc/skel/.config/

EXPOSE 22
EXPOSE 5900

# Start xdm and ssh services.
CMD ["/bin/bash", "/src/startup.sh"]