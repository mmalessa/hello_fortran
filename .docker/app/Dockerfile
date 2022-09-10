ARG BASE_IMAGE
FROM ${BASE_IMAGE} AS base

RUN apk update && apk upgrade
RUN apk add --no-cache bash git openssh make vim gfortran musl-dev

ARG DEVELOPER_UID
RUN adduser --shell /bin/sh --uid ${DEVELOPER_UID} -D developer
USER developer

ARG APP_NAME
WORKDIR /app
