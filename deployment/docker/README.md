# Galaxy Docker example deployment

If you are running Docker on OSX (Mac), first see the [related subheading below](#osx-peculiarities). 
Ensure docker can be [run without root privileges](https://docs.docker.com/engine/install/linux-postinstall/).
Change the current working directory to `/deployment/docker`. Modify `./changeme.auto.tfvars` with any custom values you like.
You must at least set the `docker_gid` variable to a group id with write access to `/var/run/docker.sock`.
Run `stat /var/run/docker.sock` (or `stat -x /var/run/docker.sock` on OSX) to show the owning group id.

Run the following to start an instance on your local computer using docker:
```shell script
terraform init
./deploy.sh
```

Browse to http://localhost:8000/ to access the deployment.

To shut down this instance, run `./destroy.sh`. This will delete the instance, all of its data, and the container images.

## OSX Peculiarities

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
See https://github.com/docker/for-mac/issues/3431 for more information about the issue.

Appropriate resources [must be allocated](https://stackoverflow.com/a/50770267/15446750) to the Docker VM or OSX will randomly kill the application and tools during an analysis.
A minimum of 8GB of RAM and 16GB of swap space is required. It is recommended to provide as much swap space as possible to avoid out of memory issues.

<!-- BEGIN_TF_DOCS -->
## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_admin_user"></a> [admin\_user](#module\_admin\_user) | ../../modules/bootstrap_admin | n/a |
| <a name="module_galaxy"></a> [galaxy](#module\_galaxy) | ../../destinations/docker | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_debug"></a> [debug](#input\_debug) | Enabling will put the deployment into a mode suitable for debugging | `bool` | n/a | yes |
| <a name="input_docker_gid"></a> [docker\_gid](#input\_docker\_gid) | GID with write permission to /var/run/docker.sock | `number` | n/a | yes |
| <a name="input_docker_socket_path"></a> [docker\_socket\_path](#input\_docker\_socket\_path) | Host path to docker socket | `string` | `"/var/run/docker.sock"` | no |
| <a name="input_email"></a> [email](#input\_email) | Email address to send automated emails from | `string` | n/a | yes |
| <a name="input_host_port"></a> [host\_port](#input\_host\_port) | Host port to expose galaxy service | `number` | n/a | yes |
| <a name="input_instance"></a> [instance](#input\_instance) | Unique deployment instance identifier | `string` | n/a | yes |
| <a name="input_microbedb_mount_path"></a> [microbedb\_mount\_path](#input\_microbedb\_mount\_path) | Path on host to mount microbedb to share with jobs | `string` | `"./microbedb/mount"` | no |
| <a name="input_worker_replicas"></a> [worker\_replicas](#input\_worker\_replicas) | Number of worker replicas | `number` | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_galaxy_admin_api_key"></a> [galaxy\_admin\_api\_key](#output\_galaxy\_admin\_api\_key) | Galaxy admin api key |
| <a name="output_galaxy_admin_password"></a> [galaxy\_admin\_password](#output\_galaxy\_admin\_password) | Galaxy admin password |
| <a name="output_galaxy_admin_username"></a> [galaxy\_admin\_username](#output\_galaxy\_admin\_username) | Galaxy admin username |
| <a name="output_galaxy_endpoint"></a> [galaxy\_endpoint](#output\_galaxy\_endpoint) | Galaxy front-end endpoint |
| <a name="output_galaxy_master_api_key"></a> [galaxy\_master\_api\_key](#output\_galaxy\_master\_api\_key) | Galaxy master api key |

## Resources

No resources.
<!-- END_TF_DOCS -->
