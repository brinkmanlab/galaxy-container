#!/usr/bin/env bash
buildah push galaxy-app docker://docker.io/brinkmanlab/galaxy-app:dev
buildah push galaxy-web docker://docker.io/brinkmanlab/galaxy-web:dev