# docker-glmark2

A multi-architecture Docker container for benchmarking GPU performance on ARM platforms using glmark2. This project simplifies the deployment of benchmarks across different hardware (NXP, Ti, Raspberry Pi, Rockchip) by containerizing the necessary graphics drivers and libraries.

## Features

- **Multi-Arch Support**: Build for `arm64` and `arm/v7` using Docker Buildx
- **Zero-Install**: Run GPU benchmarks without cluttering the host OS with dependencies
- **Portable**: Export builds as `.tar.gz` for offline deployment on embedded targets

## Installation & Building

### 1. Prerequisites

Ensure you have Docker and Buildx installed.

### 2. Build via Script

Use the provided build.sh to automate the process.

**Standard Build (Mesa/Generic ARM)**:
```bash
./build.sh -p linux/arm64 -t docker-glmark2:latest
```

If the build was successfull, docker-glmark2_linux_arm64.tar.gz


## Configuration

### Build Script Usage

The `Dockerfile` supports several build arguments (`--build-arg`) that allow you to customize the image for specific ARM vendors or OS distributions.

The included build.sh wraps these parameters into easy-to-use flags:

```bash
./build.sh [options]
```

|  Flag | Argument  | Description  |
|---|---|---|
| `-p, --platforms`  | linux/arm64,linux/arm/v7  | Target architectures (comma-separated)  |
| `-t, --tag`  | name:version  | Custom tag for the resulting image  |
| `-b, --base-image`  |  image:tag | Overrides the BASE_IMAGE argument in the Dockerfile  |
| `-s, --save`  |  None | Exports the build as a compressed .tar.gz for offline transfer  |
