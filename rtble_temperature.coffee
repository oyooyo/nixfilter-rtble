`#!/usr/bin/env node

'use strict'`

# Require the "nixfilter" module
nixfilter = require('nixfilter')

# Import/Require the "simble" module
simble = require('simble')

# The UUID of the service
service_uuid = '3e135142-654f-9090-134a-a6ff5bb77046'

# The default auto-disconnect time, in seconds
default_auto_disconnect_time = 1

# The default status update time, in seconds
default_status_update_time = 0

# Define the filter and register it on the module
nixfilter.filter module,

	# The description, as shown when running with "-h"
	description: 'Control the target temperature of a eQ-3 eqiva radiator thermostat. Reads the target temperature to set as input lines from STDIN, outputs the actual current target temperature to STDOUT (all temperatures in degrees celsius).'

	add_arguments: (argument_parser) ->
		argument_parser.addArgument ['--address', '-a'],
			help: 'The MAC address of the radiator thermostat. If omitted (not recommended), the first radiator thermostat found will be used'
		argument_parser.addArgument ['--auto_disconnect_time', '-adt'],
			type: 'float'
			defaultValue: default_auto_disconnect_time
			help: "The auto-disconnect time, in seconds. A value of 0 will deactivate auto-disconnect (usually not recommended, drains battery) (default: #{default_auto_disconnect_time})"
		argument_parser.addArgument ['--status_update_time', '-sut', '-t'],
			type: 'float'
			defaultValue: default_status_update_time
			help: "The status update time, in seconds. A value of 0 will deactivate status updates (default: #{default_status_update_time})"
		return

	setup: (args) ->
		simble.discover_peripheral
			address: args.address
			service: service_uuid
		.then (@peripheral) =>
			@peripheral.set_auto_disconnect_time(args.auto_disconnect_time * 1000)
			@send_characteristic = @peripheral.get_discovered_characteristic(service_uuid, '3fa4585a-ce4a-3bad-db4b-b8df8179ea09')
			@receive_characteristic = @peripheral.get_discovered_characteristic(service_uuid, 'd0e8434d-cd29-0996-af41-6c90f4e0eb2a')
			@receive_characteristic.subscribe (data) =>
				@on_data_received(data)
		.then =>
			@request_status()

	on_data_received: (data) ->
		switch data[0]
			when 0x02 then @on_status_update(data)
		return

	on_status_update: (status_data) ->
		clearTimeout(@status_update_timer)
		@on_target_temperature_update(status_data[5] / 2)
		if (@args.status_update_time > 0)
			@status_update_timer = setTimeout =>
					@request_status()
				, (@args.status_update_time * 1000)
		return

	on_target_temperature_update: (target_temperature) ->
		if (target_temperature isnt @target_temperature)
			@target_temperature = target_temperature
			@output(target_temperature.toString())
		return

	request_status: ->
		date = new Date()
		@send_characteristic.write([
			0x03
			(date.getFullYear() - 2000)
			(date.getMonth() + 1)
			date.getDate()
			date.getHours()
			date.getMinutes()
			date.getSeconds()
		])

	set_target_temperature: (target_temperature) ->
		target_temperature = Math.min(Math.max(target_temperature, 4.5), 30.0)
		@send_characteristic.write([0x41, Math.round(target_temperature * 2)])

	on_input: (target_temperature_string) ->
		@set_target_temperature(parseFloat(target_temperature_string))

	terminate: ->
		@peripheral.disconnect()
