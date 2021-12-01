
# bwalink

This is a docker container for https://github.com/ccutrer/balboa_worldwide_app that supports a remote serial to IP device or host running ser2net, socat or ESPEasy serial server.


There are 3 components to this solution:
- A serial to IP device
- Serial to MQTT which this docker image hosts
- MQTT to Home Assistant

*Installation and configuration of MQTT are beyond the scope of this project as there are a plethora of good articles on setting up an MQTT broker.*

## Table of Contents
- [bwalink](#bwalink)
  * [Disclaimers and Legal Stuff First](#disclaimers-and-legal-stuff-first)
  * [Serial to IP Device](#serial-to-ip-device)
    + [Elfin-EW11A-0](#elfin-ew11a-0)
      - [Setup](#setup)
      - [Connection Cable](#connection-cable)
      - [EW11 Interface Conversion Cable](#ew11-interface-conversion-cable)
  * [BWALink Docker Setup](#bwalink-docker-setup)
  * [Home Assistant Configuration](#home-assistant-configuration)
      - [Switches](#switches)
      - [Sensors](#sensors)
      - [Numbers](#numbers)
      - [Input Select](#input-select)
      - [Automations to support the selectors](#automations-to-support-the-selectors)

<small><i><a href='http://ecotrust-canada.github.io/markdown-toc/'>Table of contents generated with markdown-toc</a></i></small>

## Disclaimers and Legal Stuff First

As an Amazon Associate I earn from qualifying purchases. I get commissions for purchases made through links in this post. Most hot tubs are fed 240v and are capable of delivering 50-amps of current = 12,000 W so... electricity is dangerous and can cause personal injury or DEATH as well as other property loss or damage if not used or constructed properly. If you have any doubts whatsoever about performing do-it-yourself electrical work, PLEASE do the smart thing and hire a QUALIFIED SPECIALIST to perform the work for you.

**NEVER WORK WITH LIVE VOLTAGE**. Always disconnect the power source before working with electrical circuits.

## Serial to IP Device

### Elfin-EW11A-0
I've had great success with the [Elfin-EW11A-0](https://amzn.to/3wgRHVm) from Hi-Flying Technology. It's a simple $24 RS-485 to WiFi device that takes an input voltage of 5-18VDC, has a web interface for remote admin and an external antenna. 

#### Setup
- Supply 5-18VDC to the 2 middle screw terminals as shown [below](#ew11-interface-conversion-cable) to power up the unit
- Connect to the wireless network named `EW11_D650`
- In your browser, navigate to `10.10.100.254` and login with username: `admin` password: `admin`
- Go to the system settings page and configure the **WiFi Settings** to match your network

Value|Setting
-|-
WiFi Mode|STA
STA SSID|*your wifi SSID*
STA KEY|*your wifi password*

*Optionally* You can setup a static IP address using the **LAN Settings** section. Just remember to turn `DHCP Server` to Off.

- Click `Submit`
- Go to the **Others** page and click `Restart`
- Determine which IP the device acquired from DHCP or use the static IP you assigned and enter it in your browser
- Login with username: `admin` password: `admin`. This is a good time to change those and will only affect the web admin.
- Go to the **Serial Port Settings** section and configure as follows

Value|Setting
-|-
Baud Rate|115200
Data Bit|8
Stop Bit|1
Parity|None
Protocol|None

- Click `Submit`
- Go to the **Communication Settings** section and configure as follows

Value|Setting
-|-
Name|netp
Protocol|TCP Server
Local Port|8899
Buffer Size|512
Keep Alive(s)|60
Timeout(s)|0
Max Accept|3
Security|Disable
Route|Uart

- Click `Submit`
- Go to the **Others** page and click `Restart`

#### Connection Cable
You'll need an [ATX Molex Micro Fit Connector](https://amzn.to/3wfJYqz) to connect to the communications port of the Balboa equipment. I also recommend:
- [Silicone coated wire](https://amzn.to/2YekehL) *optional if you already have wire but much easier to work with*
- [Heat Shrink Tubing](https://amzn.to/3BDXvcp) or Electrical Tape
- [Soldering Iron](https://amzn.to/3wcwPhQ) and solder
- Good wire strippers/cutters
- Multimeter

My hot tub had a small Y-Cable hanging outside of the control box that you can plug into for power and to get to the RS-485 communications of the tub. If you don't have this cable, you can likely plug into the main control board **if** it has the same outlet type. This should be the same type of connector that goes to your control panel.

*Note that the tab is on the left of the connector*

![Y-Cable](/images/y-cable.png)

The connection is an ATX Molex Micro Fit Connector 4Pin (no, not the same as your old ATX power supply, I know, I tried too). Cut the one you ordered in half since you'll be making your own cable. Strip the ends of the ATX Molex Micro Fit connector. Be careful not to short anything and plug that into your tubs Y-cable or J33/J45 port. Confirm and tag the wires for +V, ground and RS-485 A/+ and B-, they should match the image.

Disconnect the cable and solder ~36-inches of [Silicone coated wire](https://amzn.to/2YekehL) onto each of the ends using the color that corresponds to the pin. Use some [Heat Shrink Tubing](https://amzn.to/3BDXvcp) or electrical tape to protect your soldered connections. I suggest crimping some [22AWG ferrules](https://amzn.to/3BDi8FT) to the ends of those cables or you can just tin them and be careful. 

Color|Pin/Wire
-|-
Red|DC +
Black|Ground
Yellow|RS-485 A/+
Blue|RS-485 B/-

You can now connect the wires as show in the image below to the screw block at the end of the EW11 interface cable. 

> **_NOTE:_**  You can disconnect the terminal block to make it easier to work with.



#### EW11 Interface Conversion Cable
![Y-Cable](/images/EW11-Cable.png)

Plug everything in and confirm you can access the web interface of the EW11. 

I drilled a small hole in the bottom of the hot tubs plastic media device enclosure, routed the cable in and stashed the EW11 in there. The media pocket has the added benefit of being unshielded, unlike the rest of the tub which has foil insulation.

## BWALink Docker Setup
*Installation and configuration of Docker and docker-compose are beyond the scope of this project as there are a plethora of good articles on setting up Docker.*

- Download or copy the [docker-compose.yaml](docker-compose.yaml) file and modify the `MQTT_URI` and `BRIDGE_IP` to match your set up
- Run `docker-compose up -d` and let Docker do its magic. 

> **_NOTE:_** MQTT_URI must be properly escaped, e.g. `mqtt://useename:pa##word@10.1.10.2` would need to be `mqtt://username:pa%23%23word@10.1.10.2`. See https://www.urlencoder.org/ for details.

Alternatively, you can execute `docker run --rm ghcr.io/jshank/bwalink:latest -e MQTT_URI='your_mqtt_uri' -e BRIDGE_IP='your_ew11_ip'`

If everything went well, you can subscribe to the `homie/#` topic of your MQTT broker and should see something like this:

```
homie/bwa/$homie 4.0.0
homie/bwa/$name BWA Spa
homie/bwa/$state ready
homie/bwa/$nodes spa
homie/bwa/spa/$name BWA Spa
homie/bwa/spa/$type CL501X1
homie/bwa/spa/$properties priming,heatingmode,temperaturescale,24htime,heating,temperaturerange,currenttemperature,settemperature,filter1,filter2,pump1,pump2,pump3,light1,circpump
homie/bwa/spa/priming true
homie/bwa/spa/priming/$name Is the pump priming
homie/bwa/spa/priming/$datatype boolean
homie/bwa/spa/heatingmode ready
```


## Home Assistant Configuration
If you have [MQTT Discovery](https://www.home-assistant.io/docs/mqtt/discovery/) enabled, Home Assistant will get a new BWA device along with all of the discovered sensors and switches for the spa. Otherwise, you'll need to manually create them as follows.

#### Switches
```yaml
  - platform: mqtt
    name: "Hot Tub 24hour Clock Mode"
    state_topic: "homie/bwa/spa/24htime"
    availability:
    - topic: "homie/bwa/$state"
      payload_available: "ready"
      payload_not_available: "lost"
    command_topic: "homie/bwa/spa/24htime/set"
    payload_on: "true"
    payload_off: "false"
    icon: mdi:wrench-clock
    
  - platform: mqtt
    name: "Hot Tub Pump 1 (Lounge)"
    state_topic: "homie/bwa/spa/pump1"
    availability:
    - topic: "homie/bwa/$state"
      payload_available: "ready"
      payload_not_available: "lost"
    command_topic: "homie/bwa/spa/pump1/set"
    payload_on: "toggle"
    payload_off: "toggle"
    state_on: 2
    state_off: 0
    icon: mdi:chart-bubble
  
  - platform: mqtt
    name: "Hot Tub Pump 2 (Seats)"
    state_topic: "homie/bwa/spa/pump2"
    availability:
    - topic: "homie/bwa/$state"
      payload_available: "ready"
      payload_not_available: "lost"
    command_topic: "homie/bwa/spa/pump2/set"
    payload_on: "toggle"
    payload_off: "toggle"
    state_on: 2
    state_off: 0
    icon: mdi:chart-bubble

  - platform: mqtt
    name: "Hot Tub Pump 3 (Feet)"
    state_topic: "homie/bwa/spa/pump3"
    availability:
    - topic: "homie/bwa/$state"
      payload_available: "ready"
      payload_not_available: "lost"
    command_topic: "homie/bwa/spa/pump3/set"
    payload_on: "toggle"
    payload_off: "toggle"
    state_on: 2
    state_off: 0
    icon: mdi:chart-bubble

  - platform: mqtt
    name: "Hot Tub Light"
    state_topic: "homie/bwa/spa/light1"
    availability:
    - topic: "homie/bwa/$state"
      payload_available: "ready"
      payload_not_available: "lost"
    command_topic: "homie/bwa/spa/light1/set"
    payload_on: "true"
    payload_off: "false"
    state_on: "true"
    state_off: "false"
    icon: mdi:car-parking-lights
```

#### Sensors
```yaml
- platform: mqtt
  name: "Hot Tub Circulation Pump"
  state_topic: "homie/bwa/spa/circpump"
  availability:
   - topic: "homie/bwa/$state"
     payload_available: "ready"
     payload_not_available: "lost"
  icon: mdi:sync

- platform: mqtt
  name: "Hot Tub Priming"
  state_topic: "homie/bwa/spa/priming"
  availability:
   - topic: "homie/bwa/$state"
     payload_available: "ready"
     payload_not_available: "lost"

- platform: mqtt
  name: "Hot Tub Temperature Scale"
  state_topic: "homie/bwa/spa/temperaturescale"
  availability:
   - topic: "homie/bwa/$state"
     payload_available: "ready"
     payload_not_available: "lost"

- platform: mqtt
  name: "Hot Tub Heating"
  state_topic: "homie/bwa/spa/heating"
  availability:
   - topic: "homie/bwa/$state"
     payload_available: "ready"
     payload_not_available: "lost"
  icon: mdi:hot-tub

- platform: mqtt
  name: "Hot Tub Temperature Range"
  state_topic: "homie/bwa/spa/temperaturerange"
  availability:
   - topic: "homie/bwa/$state"
     payload_available: "ready"
     payload_not_available: "lost"
  icon: mdi:thermometer-lines

- platform: mqtt
  name: "Hot Tub Current Temperature"
  state_topic: "homie/bwa/spa/currenttemperature"
  unit_of_measurement: "°F"
  availability:
   - topic: "homie/bwa/$state"
     payload_available: "ready"
     payload_not_available: "lost"

- platform: mqtt
  name: "Hot Tub Filter 1 Cycle Running"
  state_topic: "homie/bwa/spa/filter1"
  availability:
   - topic: "homie/bwa/$state"
     payload_available: "ready"
     payload_not_available: "lost"
  icon: mdi:air-filter

- platform: mqtt
  name: "Hot Tub Filter 2 Cycle Running"
  state_topic: "homie/bwa/spa/filter2"
  availability:
   - topic: "homie/bwa/$state"
     payload_available: "ready"
     payload_not_available: "lost"
  icon: mdi:air-filter
```

#### Numbers
```yaml
- platform: mqtt
  unique_id : hot_tub_set_temp
  name: "Hot Tub Set Temperature"
  state_topic: "homie/bwa/spa/settemperature"
  command_topic: "homie/bwa/spa/settemperature/set"
  min: 80
  max: 104
  availability:
  - topic: "homie/bwa/$state"
    payload_available: "ready"
    payload_not_available: "lost"
  icon: mdi:thermometer
```

#### Input Select
```yaml
input_select:
  hottub_mode:
    name: Hot Tub Mode
    options:
      - ready
      - rest
      - ready_in_rest
  hottub_temperature_range:
    name: Hot Tub Temperature Range
    options:
      - high
      - low
```

#### Automations to support the selectors
```yaml
- alias: "Update Spa Heating Mode Selector"
  trigger:
    platform: mqtt
    topic: "homie/bwa/spa/heatingmode"
   # entity_id: input_select.thermostat_mode
  action:
    service: input_select.select_option
    target:
      entity_id: input_select.hottub_mode
    data:
      option: "{{ trigger.payload }}"

- alias: "Set Hot Tub Heating Mode"
  trigger:
    platform: state
    entity_id: input_select.hottub_mode
  action:
    service: mqtt.publish
    data:
      topic: "homie/bwa/spa/heatingmode/set"
      payload: "{{ states('input_select.hottub_mode') }}"

- alias: "Update Hot Tub Temperature Range Selector"
  trigger:
    platform: mqtt
    topic: "homie/bwa/spa/temperaturerange"
   # entity_id: input_select.thermostat_mode
  action:
    service: input_select.select_option
    target:
      entity_id: input_select.hottub_temperature_range
    data:
      option: "{{ trigger.payload }}"

- alias: "Set Hot Tub Temperature Range"
  trigger:
    platform: state
    entity_id: input_select.hottub_temperature_range
  action:
    service: mqtt.publish
    data:
      topic: "homie/bwa/spa/temperaturerange/set"
      payload: "{{ states('input_select.hottub_temperature_range') }}"
```

#### Automations to heat the tub when I have excess solar and PG&E isn't charging an arm and a leg per kWH
```yaml
- alias: "Set Hot Tub Temperature Ready"
  trigger:
    platform: time
    at: "11:00:00"
  condition:
    condition: state
    entity_id: group.family
    state: "home"
  action:
    service: mqtt.publish
    data:
      topic: "homie/bwa/spa/settemperature/set"
      payload: "99"

- alias: "Set Hot Tub Temperature Standby"
  trigger:
    platform: time
    at: "17:00:00"
  action:
    service: mqtt.publish
    data:
      topic: "homie/bwa/spa/settemperature/set"
      payload: "80"
```
