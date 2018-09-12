# eqiva eQ-3 Bluetooth Smart Radiator Thermostat protocol

What I have found out about the protocol so far, for reference.

## Commands

Commands are sent by publishing to characteristic `3fa4585a-ce4a-3bad-db4b-b8df8179ea09` of service `3e135142-654f-9090-134a-a6ff5bb77046`.

### Set date/time and request status

[0x03, (Year - 2000), (Month), (Day of month), (Hours), (Minutes), (Seconds)]

### Set "Absenk-Temperatur" and "Komfort-Temperatur"

[0x11, (("Komfort-Temperatur" in degrees celsius) * 2), (("Absenk-Temperatur in degrees celsius) * 2)]

### Configure Window-open-function

[0x14, (("Window-open-temperature" in degrees celsius) * 2), (("Window-open-duration" in minutes) / 5)]

### Set mode

Automatic mode: [0x40, 0x00]

Manual mode: [0x40, 0x00]

Holiday mode: [0x40, (0x80 + ((Target temperature in degrees celsius) * 2)), (Day of month), (Year - 2000), ((Time in hours) * 2), (Month)]

### "Day mode" *(Sun symbol in app)*

[0x43]

### "Night mode" *(Moon symbol in app)*

[0x44]

### Configure boost mode

[0x45, (0x01=enable boost mode/0x02=disable boost mode)]

### Configure "Bediensperre"

[0x80, (0x01=enable "Bediensperre"/0x02=disable "Bediensperre")]

## Responses

Commands are received as notifications on characteristic `d0e8434d-cd29-0996-af41-6c90f4e0eb2a` of service `3e135142-654f-9090-134a-a6ff5bb77046`.

### Status response

[
  0x02 - This was always 0x02 so far, probably response type ID
  (This byte was always 0x01 so far)
  (Bit 7: Always 0 so far / Bit 6: Always 0 so far / Bit 5: "Bediensperre" (0=off/1=on) / Bit 3: Always 1 so far / Bit 2: Boost mode (0=off/1=on) / Bit 1: Holiday mode (0=off/1=on) / Bit 0: Manual mode (0=off=automatic mode/1=on=manual mode)
  (This byte was usually 0x00, but with boost mode enabled this was 0x50)
  (This byte was always 0x04 so far)
  ((Target temperature in degrees celsius) * 2)

  (Only available while holiday mode is enabled: Day of month)
  (Only available while holiday mode is enabled: Year - 2000)
  (Only available while holiday mode is enabled: (Time in hours) * 2)
  (Only available while holiday mode is enabled: Month)
]
