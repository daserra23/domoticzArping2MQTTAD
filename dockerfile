# Use a lightweight base image with arping and mosquitto-clients
FROM debian:bullseye-slim

# Set metadata
LABEL maintainer="Your Name <your.email@example.com>"
LABEL version="1.0"
LABEL description="Docker image for Domoticz Arping Presence MQTT AD"

# Install required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    iputils-arping \
    mosquitto-clients \
    ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy the presence-checker script into the container
COPY presence-checker.sh /usr/local/bin/presence-checker.sh

# Ensure the script is executable
RUN chmod +x /usr/local/bin/presence-checker.sh

# Set the entrypoint to the script
ENTRYPOINT ["/usr/local/bin/presence-checker.sh"]
