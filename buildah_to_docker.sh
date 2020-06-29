#!/usr/bin/env bash
buildah push galaxy_app docker-daemon:galaxy_app:dev
buildah push galaxy_web docker-daemon:galaxy_web:dev