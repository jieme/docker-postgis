#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "make update"! PLEASE DO NOT EDIT IT DIRECTLY.
#

ARG BASE_IMAGE=openanolis/anolisos:8
FROM ${BASE_IMAGE}

LABEL maintainer="PostGIS Project - https://postgis.net" \
      org.opencontainers.image.description="PostGIS 3.6.0 spatial database extension with PostgreSQL 18 Anolis OS with MVT support" \
      org.opencontainers.image.source="https://github.com/postgis/docker-postgis"

# Install PostgreSQL repository
RUN set -ex \
    && yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-$(rpm -E %{rhel})-x86_64/pgdg-redhat-repo-latest.noarch.rpm \
    && yum install -y epel-release \
    && yum clean all

# Install PostgreSQL and development packages
ENV PG_MAJOR=18
RUN set -ex \
    && yum module disable postgresql -y \
    && yum install -y --enablerepo=pgdg-common \
        postgresql${PG_MAJOR} \
        postgresql${PG_MAJOR}-server \
        postgresql${PG_MAJOR}-contrib \
        postgresql${PG_MAJOR}-libs \
        postgresql${PG_MAJOR}-devel \
    && yum clean all

# Install build dependencies for PostGIS
RUN set -ex \
    && yum groupinstall -y "Development Tools" \
    && yum install -y \
        autoconf \
        automake \
        libtool \
        make \
        gcc \
        gcc-c++ \
        cmake \
        git \
        curl \
        wget \
        bison \
        flex \
        perl-ExtUtils-Embed \
        perl-JSON \
        perl-Test-Harness \
        libxml2-devel \
        libxslt-devel \
        openssl-devel \
        readline-devel \
        zlib-devel \
        python3-devel \
        geos-devel \
        gdal-devel \
        proj-devel \
        protobuf-c-devel \
        protobuf-c-compiler \
        json-c-devel \
        libcurl-devel \
        sqlite-devel \
        pcre-devel \
        cunit-devel \
    && yum clean all

# Install runtime dependencies
RUN set -ex \
    && yum install -y \
        geos \
        gdal \
        proj \
        protobuf-c \
        json-c \
        libcurl \
        sqlite \
        pcre \
        ca-certificates \
    && yum clean all

ENV POSTGIS_VERSION=3.6.0

# Build and install PostGIS with MVT support
RUN set -ex \
    && cd /usr/src \
    && wget -O postgis.tar.gz "https://github.com/postgis/postgis/archive/${POSTGIS_VERSION}.tar.gz" \
    && tar -xzf postgis.tar.gz \
    && cd postgis-* \
    && ./autogen.sh \
    && ./configure \
        --enable-lto \
        --with-protobuf \
    && make -j$(nproc) \
    && make install \
    && cd / \
    && rm -rf /usr/src/postgis* \
    && ldconfig

# Create directory for initialization scripts
RUN mkdir -p /docker-entrypoint-initdb.d

COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/10_postgis.sh
COPY ./update-postgis.sh /usr/local/bin

# Verify PostGIS installation
RUN set -ex \
    && ldconfig \
    && psql --version \
    && postgis --version

# Set default command
CMD ["postgres"]
