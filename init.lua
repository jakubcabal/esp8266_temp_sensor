--------------------------------------------------------------------------------
-- Init file for ESP8266 temperature sensor
-- AUTHOR: Jakub Cabal
-- LICENCE: The MIT License (MIT)
-- WEBSITE: https://github.com/jakubcabal/esp8266_temp_sensor
--------------------------------------------------------------------------------

print("Starting WIFI...")
wifi.setmode(wifi.STATION)
wifi.sta.config("SSID","PASSWORD")
wifi.sta.connect()

tmr.alarm(1, 1000, 1, function() 
	if wifi.sta.getip()== nil then 
		print("No IP address...") 
	else 
		tmr.stop(1)
		dofile("temp.lua")
	end 
end)