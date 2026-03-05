#!/bin/bash
set -e

# --- Default Variables ---
PLATFORMS="linux/arm64"
TAG="docker-glmark2:latest"
SAVE_TAR=false
BASE_IMAGE=""

# --- Help Function ---
show_help() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -p, --platforms   Comma-separated platforms (default: linux/arm64)"
    echo "                    Example: linux/arm64,linux/arm/v7"
    echo "  -t, --tag         Docker image tag (default: docker-glmark2:latest)"
    echo "  -s, --save        Save output as a compressed image.tar.gz for 'docker load'"
    echo "  -b, --base-image  Override the BASE_IMAGE defined in the Dockerfile"
    echo "  -h, --help        Show this help message"
}

# --- Parse Arguments ---
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -p|--platforms) PLATFORMS="$2"; shift ;;
        -t|--tag) TAG="$2"; shift ;;
        -s|--save) SAVE_TAR=true ;;
        -b|--base-image) BASE_IMAGE="$2"; shift ;;
        -h|--help) show_help; exit 0 ;;
        *) echo "Unknown parameter passed: $1"; show_help; exit 1 ;;
    esac
    shift
done

# --- Check for Docker Buildx ---
if ! docker buildx version > /dev/null 2>&1; then
    echo "Error: Docker Buildx is not installed or enabled."
    exit 1
fi

# --- Ensure a compatible builder is active ---
docker buildx create --name glmark2-builder --driver docker-container --use || docker buildx use glmark2-builder
docker buildx inspect --bootstrap


# --- Construct Base Command ---
BUILD_CMD="docker buildx build"
if [ -n "$BASE_IMAGE" ]; then
    BUILD_CMD="$BUILD_CMD --build-arg BASE_IMAGE=$BASE_IMAGE"
fi

# --- Build Logic ---
if [ "$SAVE_TAR" = true ]; then
    # Split comma-separated platforms into an array
    IFS=',' read -ra PLATFORM_ARRAY <<< "$PLATFORMS"
    
    echo "Starting build and export for ${#PLATFORM_ARRAY[@]} platform(s)..."
    
    for PLATFORM in "${PLATFORM_ARRAY[@]}"; do
        # Create a safe filename (linux/arm64 becomes linux_arm64)
        SAFE_PLATFORM=$(echo "$PLATFORM" | tr '/' '_')
        TAR_FILE="docker-glmark2_${SAFE_PLATFORM}.tar"
        GZ_FILE="${TAR_FILE}.gz"

        echo "----------------------------------------"
        echo "Building for $PLATFORM..."
        
        # Build and export to tar
        $BUILD_CMD --platform "$PLATFORM" -t "$TAG" --output "type=docker,dest=$TAR_FILE" .
        
        echo "Compressing to $GZ_FILE..."
        gzip -f "$TAR_FILE"
        
        echo "Success: $GZ_FILE is ready."
        echo "Deploy to target board using: docker load -i $GZ_FILE"
    done
else
    echo "Running standard build for $PLATFORMS..."
    # Note: Multi-arch builds without an output destination stay in the buildx cache. 
    # Usually, you would add '--push' to send them to a registry like Docker Hub.
    $BUILD_CMD --platform "$PLATFORMS" -t "$TAG" --load .
    echo "Build complete."
fi
