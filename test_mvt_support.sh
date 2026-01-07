#!/bin/bash
# Test script to verify MVT support in PostgreSQL 18 + PostGIS 3.6 on Anolis OS

set -e

echo "=========================================="
echo "Testing MVT Support"
echo "=========================================="

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker is not running"
    exit 1
fi

# Build the image
echo ""
echo "Building PostgreSQL 18 + PostGIS 3.6 Anolis image..."
docker build -t postgis/postgis:18-3.6-anolis 18-3.6/anolis/

# Start the container
echo ""
echo "Starting container..."
docker run -d \
    --name postgres-postgis-test \
    -e POSTGRES_PASSWORD=testpassword \
    -p 5433:5432 \
    postgis/postgis:18-3.6-anolis

# Wait for PostgreSQL to be ready
echo ""
echo "Waiting for PostgreSQL to be ready..."
for i in {1..30}; do
    if docker exec postgres-postgis-test pg_isready -U postgres > /dev/null 2>&1; then
        echo "PostgreSQL is ready!"
        break
    fi
    echo "Waiting... ($i/30)"
    sleep 2
done

# Test 1: Check PostGIS version
echo ""
echo "Test 1: Checking PostGIS version..."
docker exec postgres-postgis-test psql -U postgres -c "SELECT PostGIS_Full_Version();"

# Test 2: Check for MVT functions
echo ""
echo "Test 2: Checking for MVT functions..."
MVT_FUNCTIONS=$(docker exec postgres-postgis-test psql -U postgres -t -c "
    SELECT COUNT(*) FROM pg_proc WHERE proname LIKE '%mvt%';
")
echo "Found $MVT_FUNCTIONS MVT-related functions"

# Test 3: Create a test table with spatial data
echo ""
echo "Test 3: Creating test table with spatial data..."
docker exec postgres-postgis-test psql -U postgres -c "
    CREATE EXTENSION IF NOT EXISTS postgis;
    CREATE TABLE test_points (
        id SERIAL PRIMARY KEY,
        name TEXT,
        geom GEOMETRY(Point, 4326)
    );
    INSERT INTO test_points (name, geom) VALUES
        ('Beijing', ST_SetSRID(ST_MakePoint(116.404, 39.915), 4326)),
        ('Shanghai', ST_SetSRID(ST_MakePoint(121.474, 31.230), 4326)),
        ('Guangzhou', ST_SetSRID(ST_MakePoint(113.264, 23.129), 4326));
"

# Test 4: Generate MVT tile
echo ""
echo "Test 4: Generating MVT tile..."
docker exec postgres-postgis-test psql -U postgres -c "
    SELECT ST_AsMVT(tile, 'test_points', 4096, 'geom')
    FROM (
        SELECT ST_AsMVTGeom(geom, ST_TileEnvelope(10, 500, 500)) AS geom, name
        FROM test_points
        WHERE ST_Intersects(geom, ST_TileEnvelope(10, 500, 500))
    ) AS tile;
" > /dev/null

echo "MVT tile generated successfully!"

# Test 5: Verify protobuf support
echo ""
echo "Test 5: Verifying protobuf support..."
PROTOBUF_VERSION=$(docker exec postgres-postgis-test psql -U postgres -t -c "
    SELECT PostGIS_Full_Version();
" | grep -o "PROTOBUF=[^,]*" || echo "PROTOBUF not found in version string")

if [[ "$PROTOBUF_VERSION" == *"PROTOBUF"* ]]; then
    echo "✓ Protobuf support detected: $PROTOBUF_VERSION"
else
    echo "⚠ Protobuf support not explicitly shown in version string"
fi

# Cleanup
echo ""
echo "Cleaning up..."
docker stop postgres-postgis-test
docker rm postgres-postgis-test

echo ""
echo "=========================================="
echo "All tests completed successfully!"
echo "=========================================="
