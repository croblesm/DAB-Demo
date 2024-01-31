# Start with a base image that has the necessary utilities
FROM ubuntu:20.04 as builder

# Avoiding user interaction with tzdata
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /tmp

# Update package list
RUN apt-get update

# Install necessary packages
RUN apt-get install -y curl sudo wget software-properties-common

# Add Microsoft's GPG key
RUN curl https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc

# Add Microsoft's repository
RUN sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/20.04/prod.list)"

# Update package list again and install sqlcmd
RUN sudo apt-get update && sudo apt-get install -y sqlcmd

# Clean up
RUN rm -rf /var/lib/apt/lists/*

# Final image
FROM scratch

# Copy sqlcmd from builder image
COPY --from=builder /usr/bin/sqlcmd /usr/bin/sqlcmd

# Labels
LABEL maintainer="contact@croblesm.com"
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.name="mssql-tools-scratch"
LABEL org.label-schema.description="sqlcmd-go image alternative with scratch base image"
LABEL org.label-schema.url="http://croblesm.com"

# Set sqlcmd as the entrypoint
ENV PATH=$PATH:/usr/bin/sqlcmd
CMD ["/bin/bash"]