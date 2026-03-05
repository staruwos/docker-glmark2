# Define a default base image, which can be overridden at build time
ARG BASE_IMAGE=debian:bookworm-slim
FROM ${BASE_IMAGE}

# Docker automatically injects TARGETARCH (ex, "arm64" or "arm")
ARG TARGETARCH

# NXP EULA (Torizon)
ENV ACCEPT_FSL_EULA=1

# Install glmark2-es2-wayland  and standard Mesa drivers
# Mesa drivers (Panfrost, V3D, Lima) provide open-source GPU support for many other ARM boards.
RUN apt-get update && apt-get install -y --no-install-recommends \
    glmark2-es2-wayland \
    libgles2-mesa \
    libwayland-egl1 \
    && apt-get clean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

# Set standard Wayland environment variables 
ENV XDG_RUNTIME_DIR="/tmp/1000-runtime-dir"
ENV WAYLAND_DISPLAY=wayland-0

# Command to execute when the container starts 
ENTRYPOINT ["glmark2-es2-wayland"]
CMD ["--fullscreen", "--run-forever"]
