# SQL Server Command Line Tools - custom image
# From Ubuntu 20.04
FROM ubuntu:20.04 as builder

# MSSQL_VERSION can be changed, by passing `--build-arg MSSQL_VERSION=<new version>` during docker build
ARG MSSQL_VERSION=1.5.0
ENV MSSQL_VERSION=${MSSQL_VERSION}

WORKDIR /tmp
# Installing system utilities and mssql-tools
RUN apt-get update && apt-get install -y curl gnupg software-properties-common --no-install-recommends && \
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    add-apt-repository "$(curl -s https://packages.microsoft.com/config/ubuntu/20.04/prod.list)" && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y mssql-tools unixodbc-dev && \
    apt-get remove -y curl gnupg software-properties-common && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Final image
FROM ubuntu:20.04

# Labels
LABEL maintainer="contact@croblesm.com"
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.name="mssql-tools-ubuntu"
LABEL org.label-schema.description="mssql-tools image alternative with Ubuntu"
LABEL org.label-schema.url="http://croblesm.com"

WORKDIR /
# Copying mssql-tools binaries from builder stage
COPY --from=builder /opt/mssql-tools /opt/mssql-tools
# Adding SQL Server tools to $PATH
ENV PATH=$PATH:/opt/mssql-tools/bin
CMD ["/bin/bash"]