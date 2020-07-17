#!/usr/bin/env bash
buildah push galaxy_app docker-daemon:brinkmanlab/galaxy_app:dev
buildah push galaxy_web docker-daemon:brinkmanlab/galaxy_web:dev