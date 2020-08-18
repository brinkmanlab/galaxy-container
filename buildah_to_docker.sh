#!/usr/bin/env bash
buildah push galaxy-app docker-daemon:brinkmanlab/galaxy-app:dev
buildah push galaxy-web docker-daemon:brinkmanlab/galaxy-web:dev