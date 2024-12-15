#!/bin/sh

# Read environment variables
MQTT_BROKER="${MQTT_BROKER:-192.168.2.31}"
DISCOVERY_TOPIC_PREFIX="${DISCOVERY_TOPIC_PREFIX:-presence}"
DEVICES="${DEVICES:-}"

# Validate that devices are provided
if [ -z "$DEVICES" ]; then
    echo "No devices specified. Set the DEVICES environment variable in the format: device_id:ip,device_id:ip,..."
    exit 1
fi

# Function to publish Home Assistant MQTT discovery messages
publish_discovery() {
    DEVICE=$1
    NAME=$2

    DISCOVERY_TOPIC="${DISCOVERY_TOPIC_PREFIX}/switch/${DEVICE}/config"

    MESSAGE=$(cat << EOF
{
    "name": "${NAME}",
    "unique_id": "${DEVICE}_presence",
    "state_topic": "${DISCOVERY_TOPIC_PREFIX}/${DEVICE}/state",
    "command_topic": "${DISCOVERY_TOPIC_PREFIX}/${DEVICE}/set",
    "payload_on": "online",
    "payload_off": "offline",
    "state_on": "online",
    "state_off": "offline",
    "icon": "mdi:account"
}
EOF
)

    # Publish discovery message
    mosquitto_pub -h "$MQTT_BROKER" -t "$DISCOVERY_TOPIC" -m "$MESSAGE" -r
}

# Function to check device presence using arping
check_presence() {
    IP=$1
    DEVICE=$2
    if arping -c 1 "$IP" >/dev/null 2>&1; then
        mosquitto_pub -h "$MQTT_BROKER" -t "${DISCOVERY_TOPIC_PREFIX}/${DEVICE}/state" -m "online" -r
    else
        mosquitto_pub -h "$MQTT_BROKER" -t "${DISCOVERY_TOPIC_PREFIX}/${DEVICE}/state" -m "offline" -r
    fi
}

# Process the devices list and publish discovery messages
IFS=',' # Split the DEVICES variable by commas
for DEVICE_ENTRY in $DEVICES; do
    DEVICE_ID=$(echo "$DEVICE_ENTRY" | cut -d':' -f1)
    DEVICE_IP=$(echo "$DEVICE_ENTRY" | cut -d':' -f2)
    publish_discovery "$DEVICE_ID" "Device $DEVICE_ID"
done

# Main loop to check presence of each device
while true; do
    for DEVICE_ENTRY in $DEVICES; do
        DEVICE_ID=$(echo "$DEVICE_ENTRY" | cut -d':' -f1)
        DEVICE_IP=$(echo "$DEVICE_ENTRY" | cut -d':' -f2)
        check_presence "$DEVICE_IP" "$DEVICE_ID"
    done
    sleep 60 # Run the loop every 60 seconds
done
