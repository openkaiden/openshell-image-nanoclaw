# OpenShell image for NanoClaw

An OCI sandbox image containing [NanoClaw](https://github.com/nanocoai/nanoclaw), built on the OpenShell community base image.

## Build

```sh
podman build --file Containerfile --tag openshell-image-nanoclaw .
```

The image is built for `linux/amd64` and `linux/arm64`. Published releases are available from `ghcr.io/openkaiden/openshell-image-nanoclaw`.

After starting the sandbox, run `nanoclaw` to launch NanoClaw's setup wizard.

NanoClaw uses Docker to run its per-agent containers. A Docker daemon and socket must be available to complete setup and run agents from this sandbox image.
