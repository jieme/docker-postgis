# PostgreSQL 18 + PostGIS 3.6 on Anolis OS - Setup Guide

## Overview

This setup provides a Docker image for PostgreSQL 18 with PostGIS 3.6 extension on Anolis OS 8.9, with MVT (Mapbox Vector Tiles) support enabled.

## Key Features

- **PostgreSQL 18**: Latest version with all features
- **PostGIS 3.6**: Latest PostGIS spatial database extension
- **MVT Support**: Mapbox Vector Tiles support via protobuf
- **Anolis OS 8.9**: Chinese open-source Linux distribution
- **LTO Enabled**: Link Time Optimization for better performance

## Quick Start

### 1. Build the Image

```bash
# Using the build script
chmod +x build_anolis_18.sh
./build_anolis_18.sh

# Or using Make
VERSION=18-3.6 VARIANT=anolis make build
```

### 2. Run the Container

```bash
docker run -d \
  --name postgres-postgis \
  -e POSTGRES_PASSWORD=mysecretpassword \
  -p 5432:5432 \
  postgis/postgis:18-3.6-anolis
```

### 3. Test MVT Support

```bash
chmod +x test_mvt_support.sh
./test_mvt_support.sh
```

## Configuration

### Environment Variables

- `POSTGRES_PASSWORD`: Required. Sets the superuser password
- `POSTGRES_USER`: Optional. Defaults to `postgres`
- `POSTGRES_DB`: Optional. Defaults to `postgres`

### Available PostGIS Extensions

```sql
-- Core PostGIS
CREATE EXTENSION postgis;

-- Raster support
CREATE EXTENSION postgis_raster;

-- Topology support
CREATE EXTENSION postgis_topology;

-- SFCGAL for 3D operations
CREATE EXTENSION postgis_sfcgal;

-- Address standardizer
CREATE EXTENSION address_standardizer;
CREATE EXTENSION address_standardizer_data_us;

-- Tiger geocoder
CREATE EXTENSION fuzzystrmatch;
CREATE EXTENSION address_standardizer;
CREATE EXTENSION postgis_tiger_geocoder;
```

## MVT Usage Example

```sql
-- Enable PostGIS
CREATE EXTENSION postgis;

-- Create a table with spatial data
CREATE TABLE locations (
    id SERIAL PRIMARY KEY,
    name TEXT,
    geom GEOMETRY(Point, 4326)
);

-- Insert sample data
INSERT INTO locations (name, geom) VALUES
    ('Beijing', ST_SetSRID(ST_MakePoint(116.404, 39.915), 4326)),
    ('Shanghai', ST_SetSRID(ST_MakePoint(121.474, 31.230), 4326)),
    ('Guangzhou', ST_SetSRID(ST_MakePoint(113.264, 23.129), 4326));

-- Generate MVT tile for zoom level 10
SELECT ST_AsMVT(tile, 'locations', 4096, 'geom')
FROM (
    SELECT
        ST_AsMVTGeom(geom, ST_TileEnvelope(10, 500, 500)) AS geom,
        name
    FROM locations
    WHERE ST_Intersects(geom, ST_TileEnvelope(10, 500, 500))
) AS tile;
```

## CI/CD Integration

The image is integrated into the GitHub Actions workflow (`.github/workflows/main.yml`):

```yaml
- postgres: 18
  postgis: '3.6'
  variant: anolis
  runner-platform: 'ubuntu-24.04'
```

## Makefile Integration

The Makefile has been updated to support the `anolis` variant:

```bash
# Build only anolis variant
VERSION=18-3.6 VARIANT=anolis make build

# Build all variants
VERSION=18-3.6 make build

# Test anolis variant
VERSION=18-3.6 VARIANT=anolis make test

# Push anolis variant
VERSION=18-3.6 VARIANT=anolis make push
```

## File Structure

```
docker-postgis/
├── 18-3.6/
│   └── anolis/
│       ├── Dockerfile          # Main Dockerfile for Anolis variant
│       ├── initdb-postgis.sh   # Initialization script
│       ├── update-postgis.sh   # Update script
│       └── README.md           # Detailed documentation
├── Dockerfile.anolis.template # Template for generating Anolis Dockerfiles
├── Makefile                    # Updated to support anolis variant
├── build_anolis_18.sh          # Build script for Anolis 18
├── test_mvt_support.sh        # Test script for MVT support
└── ANOLIS_SETUP.md            # This file
```

## Troubleshooting

### Build Issues

If you encounter build issues:

1. Ensure Docker has sufficient resources (at least 4GB RAM)
2. Check network connectivity for downloading packages
3. Verify Anolis OS 8.9 image is available

### MVT Support Verification

To verify MVT support is working:

```bash
docker exec -it postgres-postgis psql -U postgres -c "
SELECT PostGIS_Full_Version();
"
```

Look for protobuf-related information in the output.

### Performance Optimization

The image uses LTO (Link Time Optimization) for better performance. If you need to build without LTO, modify the Dockerfile and remove the `--enable-lto` flag from the configure command.

## Additional Resources

- [PostGIS Documentation](https://postgis.net/documentation/)
- [MVT Functions](https://postgis.net/docs/manual-3.6/reference_output.html#mvt_functions)
- [Anolis OS](https://openanolis.org/)
- [PostgreSQL 18 Documentation](https://www.postgresql.org/docs/18/)

## Contributing

When making changes to the Anolis variant:

1. Update the Dockerfile in `18-3.6/anolis/Dockerfile`
2. Test the build using `./build_anolis_18.sh`
3. Test MVT support using `./test_mvt_support.sh`
4. Update documentation as needed

## License

This setup follows the same license as the main docker-postgis project.
