#!/bin/bash
# Build script for PostgreSQL 18 + PostGIS 3.6 on Anolis OS

set -e

echo "=========================================="
echo "Building PostgreSQL 18 + PostGIS 3.6"
echo "Base OS: Anolis 8.9"
echo "Features: PostGIS + MVT support"
echo "=========================================="

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker is not running"
    exit 1
fi

# Build the image
echo ""
echo "Building Docker image..."
docker build -t jieme/postgis:18-3.6-anolis 18-3.6/anolis/

echo ""
echo "=========================================="
echo "Build completed successfully!"
echo "=========================================="
echo ""
echo "Image: jieme/postgis:18-3.6-anolis"
echo ""
echo "To run the container:"
echo "  docker run -d --name postgres-postgis \\"
echo "    -e POSTGRES_PASSWORD=mysecretpassword \\"
echo "    -p 5432:5432 \\"
echo "    jieme/postgis:18-3.6-anolis"
echo ""
echo "To test MVT support:"
echo "  ./test_mvt_support.sh"
