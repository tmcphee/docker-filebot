# set base image (host OS)
FROM debian:stable-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN mkdir -p /usr/share/man/man1 /usr/share/man/man2

RUN apt-get update && \
apt-get install -y --no-install-recommends openjdk-11-jre

RUN apt-get install wget -y

RUN wget --no-check-certificate -q -O filebot.deb \
'https://github.com/barry-allen07/FB-Mod/releases/download/4.8.5/FileBot_4.8.5_amd64.deb' && \
dpkg -i filebot.deb && rm filebot.deb

RUN apt-get install python3 -y
RUN apt-get install python3-pip -y
RUN python3 --version

RUN apt-get install libmediainfo0v5 -y

#--------------------------------------------------------------

RUN pip3 install --upgrade pip 

COPY requirements.txt .
RUN pip install -r requirements.txt

RUN apt-get install -y locales locales-all

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Create dir to keep things tidy. Make sure it's readable by $USER_ID
RUN mkdir /files && \
chmod a+rwX /files

RUN mkdir /files/scripts && \
chmod a+rwX /files/scripts

# Download the FileBot Scripts
RUN wget -O - https://github.com/barry-allen07/FB-Mod-Scripts/archive/master.tar.gz | tar xz -C /files/scripts --strip=1 "FB-Mod-Scripts-master" 

# Add scripts. Make sure everything is executable
COPY start.sh monitor.sh filebot.sh monitor.py /files/
RUN chmod a+x /files/start.sh
RUN chmod +x /files/monitor.py

ENTRYPOINT ["./files/start.sh"]

