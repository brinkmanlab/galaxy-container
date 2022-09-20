# Contributing to this repo

## Upgrade Galaxy

Galaxy tracks its releases in its [repo](https://github.com/galaxyproject/galaxy/) as branches, with `release_` as a prefix. Patches are committed to
these branches after the official release to fix any issues. The current Galaxy version being built by this repository is tracked as
a [git submodule](https://git-scm.com/book/en/v2/Git-Tools-Submodules) in the `./galaxy` folder. If you did not clone this repo with
the `--recurse-submodules` then you need to run `git submodule init && git submodule update` or the galaxy folder will appear empty.

Once the submodule is ready it will be populated with the last version of Galaxy to be committed to this repo. To switch to a newer version, you
can `cd` into the galaxy folder and pull/checkout the latest branch or commit that you want to build.

Newer versions of Galaxy may require changes to the container and deployment recipes. See [The GalaxyProject News](https://galaxyproject.org/news/)
for release details.

To save the currently checked out version of the galaxy repo, `cd` back to the parent repo and run `git add ./galaxy && git commit -m "Update galaxy"`
.

## Build container

To build the containers, ensure you have buildah, docker, terraform, and ansible-playbook installed and configured. Ensure docker can
be [run without root privileges](https://docs.docker.com/engine/install/linux-postinstall/).

You do not need to build the containers to deploy an instance of Galaxy. Rebuilding the container is only needed if you want to customise them. There
are pre-built containers already published to docker hub that work for most use cases.

Run `./webserver.playbook.yml` to build the web server container. Run `./application.playbook.yml` to build the Galaxy app container.
Run `./buildah_to_docker.sh` to push the built containers to your local docker instance for testing.
