ARG TOOL=golang

FROM ghcr.io/linuxsuren/hd as hd
ARG TOOL

FROM jenkins/inbound-agent:4.10-3-jdk11
ARG TOOL

COPY --from=hd /usr/local/bin/hd /usr/local/bin/hd

USER root
RUN hd fetch
RUN hd i ubuntu-source-aliyun
RUN hd i ${TOOL}
