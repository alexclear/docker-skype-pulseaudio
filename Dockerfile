FROM debian:stable
MAINTAINER Tom Parys "tom.parys+copyright@gmail.com"

# Tell debconf to run in non-interactive mode
ENV DEBIAN_FRONTEND noninteractive

# Setup multiarch because Skype is 32bit only
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y libpulse0:i386 pulseaudio:i386 && \
    apt-get install -y openssh-server wget && \
    wget http://download.skype.com/linux/skype-debian_4.3.0.37-1_i386.deb -O /usr/src/skype.deb && \
    dpkg -i /usr/src/skype.deb || true && \
    apt-get install -fy && \
    useradd -m -d /home/docker docker && \
    echo "docker:docker" | chpasswd && \
    mkdir -p /var/run/sshd && \
    echo X11Forwarding yes >> /etc/ssh/ssh_config && \
    mkdir /home/docker/.ssh && \
    chown -R docker:docker /home/docker && \
    chown -R docker:docker /home/docker/.ssh && \
    localedef -v -c -i en_US -f UTF-8 en_US.UTF-8 || true && \
    echo "Europe/Moscow" > /etc/timezone && \
    echo 'export PULSE_SERVER="tcp:localhost:64713"' >> /usr/local/bin/skype-pulseaudio && \
    echo 'PULSE_LATENCY_MSEC=60 skype' >> /usr/local/bin/skype-pulseaudio && \
    chmod 755 /usr/local/bin/skype-pulseaudio


# Expose the SSH port
EXPOSE 22

# Start SSH
ENTRYPOINT ["/usr/sbin/sshd",  "-D"]
