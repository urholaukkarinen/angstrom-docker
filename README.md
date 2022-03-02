# Angström-docker-qemu

Dockerized qemux86-64 build of Angström Linux.

## Building

To build the Docker image, run the following command:
```bash
docker build --tag angstrom .
```
This may take several hours, depending on how powerful your system is.
Beware that the resulting image(s) will be very large, because at the moment the image will also contain the full build cache.

## Usage

```bash
docker run -it angstrom
```