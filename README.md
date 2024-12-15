# domoticzArping2MQTTAD

##### Don't try to use this yet, work in progress #####

A docker to create MQTT topics for devices connected on the local network using Arping instead of ping for reliability.

Installation

Clone repo into your chosen directory , eg /home/ with

	git clone https://github.com/your-username/domoticz-arping-presence-mqtt-ad.git
	
Alter the devices and IP's as mentioned below under "Environment Variable DEVICES"

Then bring up the docker enviroment and start the script with

	docker-compose up --build -d


Explanation

Environment Variable DEVICES:

The DEVICES variable defines all devices as device_id:ip pairs, separated by commas.
Example: "device1:192.168.2.12,device2:192.168.2.13"

Dynamic Device Handling:

The script splits the DEVICES variable using commas and iterates over each device_id:ip pair.
cut extracts the device ID (device1, device2, etc.) and the IP address.
Discovery and Presence Checks:

The discovery message is published for every device during initialization.
The presence check runs in a loop, evaluating each device's IP.
Scalability:

You can add or remove devices in docker-compose.yml without modifying the script.
Running the Project
Build and start the container:

	docker-compose up --build -d

Add more devices:

Edit docker-compose.yml and update the DEVICES environment variable.
Restart the container:

	docker-compose down && docker-compose up -d

