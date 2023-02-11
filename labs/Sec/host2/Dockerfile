FROM host1

RUN apt update && apt dist-upgrade -y && apt-get install -y ufw && apt-get install -y openssh
# RUN apt-get update && apt-get install -y ufw
# RUN apt-get install --reinstall -y iptables

RUN update-alternatives --set iptables /usr/sbin/iptables-legacy

RUN apt-get install -y net-tools
RUN apt-get install -y mc

RUN mkdir -p /opt/vol

