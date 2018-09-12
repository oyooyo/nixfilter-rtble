# nixfilter-rtble

[Filter](https://en.wikipedia.org/wiki/Filter_(software)#Unix) *(non-interactive command-line tool reading from STDIN and writing to STDOUT)* for controlling the target temperature of an [eqiva eQ-3 Bluetooth Smart Radiator Thermostat](https://www.eq-3.com/products/eqiva/bluetooth-smart-radiator-thermostat.html).

## Installation

    $ npm install -g --unsafe-perm nixfilter-rtble

Requires [Node.js](https://nodejs.org/) and Bluetooth 4.x capable hardware.

## Command-line tools

### `nixfilter-rtble-temperature`

`nixfilter-rtble-temperature` reads and writes the target temperature of an eqiva eQ-3 Bluetooth Smart Radiator Thermostat. To set the target temperature, write a line with a float value in degrees celsius to the program's STDIN. If the target temperature changes, the program will write the new target temperature to STDOUT.

In order to save the thermostat's battery, the Bluetooth connection will be automatically closed after `--auto_disconnect_time` seconds of inactivity. In order to also recognize and output manual changes to the target temperature, the program requests status updates every `--status_update_time` seconds. This requires connecting to the thermostat, so in order to save the thermostat's battery, it is advised to set this value *as high as possible, as low as necessary*. Or, simply turn status updates off by setting `--status_update_time` to 0.

    $ nixfilter-rtble-temperature -h
    
    usage: nixfilter-rtble-temperature [-h] [--address ADDRESS]
                                       [--auto_disconnect_time AUTO_DISCONNECT_TIME]
                                       [--status_update_time STATUS_UPDATE_TIME]
                                
    
    Control the target temperature of a eQ-3 eqiva radiator thermostat. Reads the 
    target temperature to set as input lines from STDIN, outputs the actual 
    current target temperature to STDOUT (all temperatures in degrees celsius).
    
    Optional arguments:
      -h, --help            Show this help message and exit.
      --address ADDRESS, -a ADDRESS
                            The MAC address of the radiator thermostat. If 
                            omitted (not recommended), the first radiator 
                            thermostat found will be used
      --auto_disconnect_time AUTO_DISCONNECT_TIME, -adt AUTO_DISCONNECT_TIME
                            The auto-disconnect time, in seconds. A value of 0 
                            will deactivate auto-disconnect (usually not 
                            recommended, drains battery) (default: 1)
      --status_update_time STATUS_UPDATE_TIME, -sut STATUS_UPDATE_TIME, -t STATUS_UPDATE_TIME
                            The status update time, in seconds. A value of 0 will 
                            deactivate status updates (default: 0)

#### Using `nixfilter-rtble-temperature` as a Filter

`nixfilter-rtble-temperature` is intended to be used as a [Filter](https://en.wikipedia.org/wiki/Filter_(software)#Unix), reading from STDIN and writing to STDOUT. The following command line demonstrates how to make use of this, by using the *mosquitto-clients* tools *(`sudo apt-get install mosquitto-clients`)* to make the radiator thermostat accessable via MQTT:

    $ mosquitto_sub -h 192.168.0.12 -t "thermostat/temperature/set" | nixfilter-rtble-temperature -a 00:11:22:33:44:55 -sut 300 | mosquitto_pub -l -r -h 192.168.0.12 -t "thermostat/temperature"

The above command assumes a MQTT broker with IP address 192.168.0.12 and a radiator thermostat with MAC address 00:11:22:33:44:55. In order to set the target temperature, publish a MQTT message like "23.5" *(=degrees celsius)* to MQTT topic "thermostat/temperature/set". The actual target temperature will automatically be published as retained messages to MQTT topic "thermostat/temperature", and will be checked for changes every 300 seconds.
