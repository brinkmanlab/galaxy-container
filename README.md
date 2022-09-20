# Galaxy container and deployment

The repository contains everything needed to build a container for Galaxy and deploy to a cloud resource.
Example deployments are provided in the `./deployment` folder for various destinations. For production use, it is
recommended to create your own deployment recipe using the terraform modules provided in `./desinations`. Terraform
is the deployment manager software used for all deployment destinations.

The deployment can be further customized including installing tools using the [Galaxy Terraform Provider](https://registry.terraform.io/providers/brinkmanlab/galaxy/latest/docs)

To install terraform, check that your systems package manager provides it or download it from [here](https://www.terraform.io/downloads.html).

See the [awesome-galaxy](https://github.com/galaxyproject/awesome-galaxy) repo for more Galaxy resources.

## Run local
See [deployment/docker/](deployment/docker/) for instructions.

## Deploy to cloud

Several terraform destinations have been configured. Select one from the `./destinations/` folder that you wish to use.

### AWS
See [deployment/aws/](deployment/aws/) for instructions.

### Azure
TODO

### Google Cloud
TODO

### OpenStack
TODO

### Kubernetes

All cloud deployments include a dashboard server that provides administrative control of the cluster.
To access it, [install kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) and run `kubectl proxy` in a separate terminal.
Visit [here](http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login) to
access the dashboard.

To check the state of the cluster run `kubectl describe node`.
To restart a deployment run `kubectl rollout restart -n galaxy deployment galaxy-worker`.

### Existing Kubernetes cluster

Configure the Kubernetes terraform provider and deploy the `./destinations/k8s` module.

### Existing Nomad cluster

Configure the Nomad terraform provider and deploy the `./destinations/nomad` module.

## Project layout

See [CONTRIBUTING.md](CONTRIBUTING.md) for more information on maintaining the containers.

### Container generation

Buildah and ansible are the tools used to generate the containers. The relevant paths are:

* `./roles` - Ansible roles applied to the container
* `./*.playbook.yml` - Run this to begin building the containers
* `./galaxy` - Galaxy sub repository, initialise it by running `git submodule update --init`
* `./buildah_to_*.sh` - Push the built container to the local docker daemon or docker hub
* `./vars.yml` - Various configuration options for the container build process. Also imported by the deployment recipes.

### Deployment

Terraform is used to deploy the various resources needed to run Galaxy to the cloud provider of choice.

* `./destinations` - Terraform modules responsible for deployment into the various providers
* `./deployment` - Usage examples for the destination modules