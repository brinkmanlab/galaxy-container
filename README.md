# Galaxy container and deployment

The repository contains everything needed to build a container for Galaxy and deploy to a cloud resource.
Example deployments are provided in the `./deployment` folder for various destinations. For production use, it is
recommended to create your own deployment recipe using the terraform modules provided in `./desinations`. Terraform
is the deployment manager software used for all deployment destinations.

The deployment can be further customized including installing tools using the [Galaxy Terraform Provider](https://registry.terraform.io/providers/brinkmanlab/galaxy/latest/docs)

To install terraform, check that your systems package manager provides it or download it from [here](https://www.terraform.io/downloads.html).

## Run local
If you are running Docker on OSX (Mac), first see the [related subheading below](#osx-peculiarities). 
Ensure docker can be [run without root privileges](https://docs.docker.com/engine/install/linux-postinstall/).
Change the current working directory to `./deployment/docker`. Modify `./changeme.auto.tfvars` with any custom values you like.
You must at least set the `docker_gid` variable to a group id with write access to `/var/run/docker.sock`.
Run `stat /var/run/docker.sock` (or `stat -x /var/run/docker.sock` on OSX) to show the owning group id.

Run the following to start an instance on your local computer using docker:
```shell script
terraform init
./deploy.sh
```

Browse to http://localhost:8000/ to access the deployment.

To shut down this instance, run `./destroy.sh`. This will delete the instance, all of its data, and the container images. Docker may fail to unmount
CVMFS during shutdown, run `sudo fusermount -u ./microbedb/mount` if you encounter `transport endpoint is not connected` errors.

### OSX Peculiarities

OSX does not natively support Docker, it runs Docker within a Linux virtual machine. This workaround means that support is limited to only the most
basic use case. The following needs to be added to `changeme.auto.tfvars`:

```hcl
docker_gid = 0
docker_socket_path = "/run/host-services/docker.proxy.sock"
```

The last modification you need to make is to allow group write access to the docker socket within containers. To do this run the following:
```shell
docker run --rm -v /run/host-services/docker.proxy.sock:/run/host-services/docker.proxy.sock alpine chmod g+w /run/host-services/docker.proxy.sock
```

This command must be run any time you restart your system, before you can run deploy.sh or submit analysis.

Appropriate resources [must be allocated](https://stackoverflow.com/a/50770267/15446750) to the Docker VM or OSX will randomly kill the application and tools during an analysis.
A minimum of 8GB of RAM and 16GB of swap space is required. It is recommended to provide as much swap space as possible to avoid out of memory issues.

See https://github.com/docker/for-mac/issues/3431 for more information about the issue.


## Deploy to cloud

Several terraform destinations have been configured. Select one from the `./destinations/` folder that you wish to use.
Modify `./changeme.auto.tfvars` with any custom values you like. Ensure you are authenticated with your cloud provider
and that the required environment variables are set for the respective terraform provider. Review the relevant cloud provider section below
for additional configuration. Once fully prepared, run `./deploy.sh` to deploy the application to the cloud.

### AWS

Select the region to deploy to by exporting `export AWS_DEFAULT_REGION='us-west-2'` or creating an aws provider configuration block in the terraform definitions.
See the [supported regions for EKS](https://docs.aws.amazon.com/general/latest/gr/eks.html) as not all regions support deployment. This step is independent of the default region setting in the next step.

Install the [AWS CLI tool](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) and [aws-iam-authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html).
Configure the aws cli tool by running `aws configure` and fill in the requested info. Proceed with deployment.

Additionally:
Configure `kubectl` by running `aws eks --region us-west-2 update-kubeconfig --name galaxy`.
Refer to the Kubernetes section for the remaining information.

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

## Build container
To build the containers, ensure you have buildah, docker, terraform, and ansible-playbook installed and configured.
Ensure docker can be [run without root privileges](https://docs.docker.com/engine/install/linux-postinstall/).

You do not need to build the containers to deploy an instance of Galaxy. Rebuilding the container is only needed if you want to
customise them. There are pre-built containers already published to docker hub that work for most use cases.

Run `./webserver.playbook.yml` to build the web server container.
Run `./application.playbook.yml` to build the Galaxy app container.
Run `./buildah_to_docker.sh` to push the built containers to your local docker instance for testing.

## Project layout

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