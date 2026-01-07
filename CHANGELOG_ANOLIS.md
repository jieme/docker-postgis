# Changelog - Anolis OS Support for PostgreSQL 18 + PostGIS 3.6

## Summary

Added support for building PostgreSQL 18 with PostGIS 3.6 on Anolis OS 8.9, with MVT (Mapbox Vector Tiles) support enabled.

## Changes Made

### 1. New Files Created

- `Dockerfile.anolis.template` - Template for generating Anolis OS-based Dockerfiles
- `18-3.6/anolis/Dockerfile` - Complete Dockerfile for PostgreSQL 18 + PostGIS 3.6 on Anolis OS
- `18-3.6/anolis/initdb-postgis.sh` - Initialization script (copied from root)
- `18-3.6/anolis/update-postgis.sh` - Update script (copied from root)
- `18-3.6/anolis/README.md` - Documentation for the Anolis variant
- `build_anolis_18.sh` - Build script for the Anolis 18 variant
- `test_mvt_support.sh` - Test script to verify MVT support
- `ANOLIS_SETUP.md` - Complete setup guide for Anolis OS variant
- `CHANGELOG_ANOLIS.md` - This changelog file

### 2. Modified Files

#### Makefile
- Added `do_anolis=true` flag for Anolis variant support
- Updated `build-version` rule to build Anolis variant when `do_anolis=true`
- Updated `test-version` rule to test Anolis variant
- Updated `push-version` rule to push Anolis variant
- Added logic to detect and handle `VARIANT=anolis` parameter

#### .github/workflows/main.yml
- Added matrix entry for PostgreSQL 18 + PostGIS 3.6 + Anolis variant
- Configuration:
  ```yaml
  - postgres: 18
    postgis: '3.6'
    variant: anolis
    runner-platform: 'ubuntu-24.04'
  ```

## Features

### PostGIS 3.6 with MVT Support
- **MVT (Mapbox Vector Tiles)**: Enabled via `--with-protobuf` configure option
- **LTO (Link Time Optimization)**: Enabled for better performance
- **Full PostGIS Extensions**: All standard PostGIS extensions available

### Anolis OS 8.9 Base
- Chinese open-source Linux distribution
- Compatible with CentOS/RHEL 8
- Uses PostgreSQL official yum repository
- Includes EPEL repository for additional packages

### Build Dependencies
The image includes all necessary build-time dependencies:
- PostgreSQL 18 development packages
- GEOS, GDAL, PROJ development libraries
- Protocol Buffers (protobuf-c) for MVT support
- JSON-C, libcurl, and other required libraries
- Development tools: gcc, make, cmake, autoconf, etc.

### Runtime Dependencies
Minimal runtime dependencies for production use:
- PostgreSQL 18 runtime
- GEOS, GDAL, PROJ runtime libraries
- Protocol Buffers runtime
- JSON-C, libcurl, and other required libraries

## Usage

### Build
```bash
# Using Make
VERSION=18-3.6 VARIANT=anolis make build

# Using build script
./build_anolis_18.sh
```

### Run
```bash
docker run -d \
  --name postgres-postgis \
  -e POSTGRES_PASSWORD=mysecretpassword \
  -p 5432:5432 \
  postgis/postgis:18-3.6-anolis
```

### Test
```bash
./test_mvt_support.sh
```

## Verification

The test script verifies:
1. PostGIS version and installation
2. MVT functions availability
3. MVT tile generation
4. Protobuf support

## CI/CD

The Anolis variant is integrated into the GitHub Actions workflow and will be built automatically on:
- Push to master branch
- Pull requests
- Scheduled weekly builds (Monday 5:15 AM UTC)

## Future Enhancements

Potential improvements for future versions:
1. Multi-stage build to reduce image size
2. Add ARM64 support for Anolis variant
3. Optimize build time with caching
4. Add more comprehensive test suite
5. Include performance benchmarks

## Compatibility

- **Docker**: Requires Docker 17.05 or later (for multi-stage builds)
- **PostgreSQL**: Version 18
- **PostGIS**: Version 3.6
- **Anolis OS**: Version 8.9
- **Architecture**: x86_64 (ARM64 support can be added)

## Notes

1. The Anolis variant is currently only available for PostgreSQL 18 with PostGIS 3.6
2. The image includes build tools, making it larger than the default Debian variant
3. For production use, consider using a multi-stage build to reduce image size
4. MVT support is enabled by default and requires protobuf libraries

## References

- [PostGIS MVT Functions](https://postgis.net/docs/manual-3.6/reference_output.html#mvt_functions)
- [Anolis OS](https://openanolis.org/)
- [PostgreSQL 18 Documentation](https://www.postgresql.org/docs/18/)
