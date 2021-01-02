# docker-filebot
#### FileBot 4.8.5 
This is a Docker container running [FileBot](https://www.filebot.net/), a organizing and renaming tool. 

The docker image is available [here](https://hub.docker.com/r/tmcphee/docker-filebot)

## Usage
> docker run --name=FileBot -d -v /path/to/config:/config:rw -v /path/to/input:/input:rw -v /path/to/media:/media:rw tmcphee/docker-filebot

## Sources
The creation of this docker image included the use of the following GitHub repositories:
* https://github.com/coppit/docker-filebot
* https://github.com/barry-allen07/FB-Mod
* https://github.com/barry-allen07/FB-Mod-Scripts
