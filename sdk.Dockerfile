#sdk:1
FROM ubuntu:24.04 AS sdk

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update -y \
  && apt upgrade -y \
  && apt install -y 
