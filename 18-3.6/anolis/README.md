# PostgreSQL 18 + PostGIS 3.6 on Anolis OS

This Docker image provides PostgreSQL 18 with PostGIS 3.6 extension on Anolis OS 8.2, with MVT (Mapbox Vector Tiles) support enabled.

## Features

- **PostgreSQL 18**: Latest version of PostgreSQL
- **PostGIS 3.6**: Latest version of PostGIS spatial database extension
- **MVT Support**: Mapbox Vector Tiles support enabled via `--with-protobuf` configure option
- **Anolis OS 8.2**: Chinese open-source Linux distribution compatible with CentOS/RHEL
- **LTO Enabled**: Link Time Optimization for better performance

## Build

To build this image:

```bash
# Build only the Anolis variant
VERSION=18-3.6 VARIANT=anolis make build

# Or build all variants
VERSION=18-3.6 make build
```

## Usage

### Run the container

```bash
docker run -d \
  --name postgres-postgis \
  -e POSTGRES_PASSWORD=mysecretpassword \
  -p 5432:5432 \
  jieme/postgis:18-3.6-anolis
```

### Verify MVT support

```bash
docker exec -it postgres-postgis psql -U postgres -c "
CREATE EXTENSION postgis;
SELECT PostGIS_Full_Version();
"
```

The output should show that PostGIS is installed with protobuf support.

### Create a table with MVT support

```sql
-- Enable PostGIS
CREATE EXTENSION postgis;

-- Create a sample table
CREATE TABLE sample_data (
  id SERIAL PRIMARY KEY,
  name TEXT,
  geom GEOMETRY(Point, 4326)
);

-- Insert some data
INSERT INTO sample_data (name, geom) VALUES
  ('Point 1', ST_SetSRID(ST_MakePoint(116.404, 39.915), 4326)),
  ('Point 2', ST_SetSRID(ST_MakePoint(121.474, 31.230), 4326));

-- Create MVT tiles
SELECT ST_AsMVT(tile, 'sample_data', 4096, 'geom')
FROM (
  SELECT ST_AsMVTGeom(geom, ST_TileEnvelope(10, 500, 500)) AS geom, name
  FROM sample_data
  WHERE ST_Intersects(geom, ST_TileEnvelope(10, 500, 500))
) AS tile;
```

## Environment Variables

- `POSTGRES_PASSWORD`: Required. Sets the superuser password
- `POSTGRES_USER`: Optional. Defaults to `postgres`
- `POSTGRES_DB`: Optional. Defaults to `postgres`

## PostGIS Extensions Available

- `postgis`: Core PostGIS extension
- `postgis_raster`: Raster support
- `postgis_topology`: Topology support
- `postgis_sfcgal`: SFCGAL support (3D operations)
- `address_standardizer`: Address standardizer
- `address_standardizer_data_us`: US address data
- `postgis_tiger_geocoder`: Tiger geocoder
- `fuzzystrmatch`: Fuzzy string matching

## Build Dependencies

The image includes the following build-time dependencies:

- PostgreSQL 18 development packages
- GEOS (Geometry Engine)
- GDAL (Geospatial Data Abstraction Library)
- PROJ (Cartographic projections)
- Protocol Buffers (protobuf-c) for MVT support
- JSON-C
- Various development tools (gcc, make, cmake, etc.)

## Notes

- This image uses Anolis OS 8.2 as the base
- MVT support is enabled by default
- The image size will be larger due to the inclusion of build tools
- For production use, consider using a multi-stage build to reduce image size
