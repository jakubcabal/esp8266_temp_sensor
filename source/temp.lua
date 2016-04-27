--------------------------------------------------------------------------------
-- Get temp from DS18B20 and send data to thingspeak.com
-- AUTHOR: Jakub Cabal <jakubcabal@gmail.com>
-- LICENCE: The MIT License (MIT)
-- WEBSITE: https://github.com/jakubcabal/esp8266_temp_sensor
--------------------------------------------------------------------------------

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function sendData()
    
    -- load DS18B20 module for NodeMCU and setup it
	t = require("ds18b20")
	t.setup(3)
	addrs = t.addrs()

	-- read temperature from sensor
	print("Read teperature...")
	t1 = t.read()
	while (t1 == 85) do -- if temp is reset value (85°C), then read temp again
      t1 = t.read()
    end

    temp = round(t1, 1)
	print("Temperature is "..temp.."'C")

	-- release after use
	t = nil
	ds18b20 = nil
	package.loaded["ds18b20"]=nil

	-- conection to thingspeak.com
	print("Sending data to thingspeak.com")
	conn=net.createConnection(net.TCP, 0) 
	conn:on("receive", function(conn, payload) print(payload) end)
	-- api.thingspeak.com 184.106.153.149
	conn:connect(80,'184.106.153.149') 
	conn:send("GET /update?key=YOURKEY&field1="..temp.." HTTP/1.1\r\n") 
	conn:send("Host: api.thingspeak.com\r\n") 
	conn:send("Accept: */*\r\n") 
	conn:send("User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n")
	conn:send("\r\n")
	conn:on("sent", function(conn)
    	print("Closing connection")
        conn:close()
    end)
	conn:on("disconnection", function(conn)
        print("Disconnection...")
   	end)
	
end

-- first send data after turn on
print("First send data after turn on")
sendData()
-- send data every 15 min (900000 ms) to thingspeak.com
tmr.alarm(0, 900000, 1, function()
	sendData()
end)