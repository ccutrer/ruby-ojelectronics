# OJ Electronics Gem

This gems connects to the OJ Electronics cloud service for floor heating
thermostats. It uses the long-poll notification based model to keep
information up to date with minimal resource usage. Schluter DITRA-HEAT
thermostats are also supported.

## Usage

An MQTT bridge is provided to allow easy integration into other systems. You
will need a separate MQTT server running ([Mosquitto](https://mosquitto.org) is
a relatively easy and robust one). The MQTT topics follow the [Homie
convention](https://homieiot.github.io), making them self-describing. If you're
using a systemd Linux distribution, an example unit file is provided in
`contrib/oj_electronics_mqtt_bridge.service`. So a full example would be (once you have
Ruby installed):

```sh
sudo gem install ojelectronics
sudo curl https://github.com/ccutrer/ruby-ojelectronics/raw/main/contrib/oj_electronics_mqtt_bridge.service -L -o /etc/systemd/system/oj_electronics_mqtt_bridge.service
<modify the file to pass the authenticatin information>
<If you use MQTT authentication you can use the following format to provide login information mqtt://username:password@mqtt.domain.tld >
<Make sure to change the "User" parameters to fit your environnement>
sudo systemctl enable oj_electronics_mqtt_bridge
sudo systemctl start oj_electronics_mqtt_bridge
```
