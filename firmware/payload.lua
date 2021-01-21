local M
do
  local self = {
  }

  local early = function()
    -- Nothing happens here.
  end

  local main = function()
    bme680wrap = require ("bme680wrap")
    ccs811wrap = require ("ccs811wrap")
    pms5003 = require ("pms5003")

    print("\nStarting main handler...\n====================")
    print("Have myname: "..myname)
    print("Have location: "..location)
    print("\n")

    bme680_id  = 0
    bme680_sda = 3
    bme680_scl = 4

    css811_id  = 0
    css811_sda = nil --1
    css811_scl = nil --2

    ---------------
    -- BME680 setup
    ---------------
    print("setting up bme680...")
    bme680wrap.on("datapoint", function(d)
      local tm = rtctime.epoch2cal(d.epochtime)
      infix = d.epochtime > time_boot + bme680wrap.uptime_before_gas_sensor_trusted_s and string.format(',"gas_resistance":%d', d.G) or ""
      buf = string.format('{"ts":"%04d-%02d-%02dT%02d:%02d:%02dZ","type":"bme680","location": "%s", "device":"'..myname..'","T":%.2f,"QFE":%.2f,"QNH":%.2f,"humidity":%.3f,"dew_point":%.2f%s}',
        tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"],
        location,
        d.T,
        d.QFE,
        d.QNH,
        d.H,
        d.D,
        infix)
      ccs811wrap.push_temperature_humidity(d.T,d.H)

      --print("publishing bme680 data point:"..buf)
      mqttwrap.maybepublish("datainput/"..location.."/"..myname, buf, 0, 0)
    end)
    bme680wrap.setup(bme680_sda, bme680_scl, bme680_id)
    bme680wrap.starttimer(60*1000)

    -----------------
    -- PMS5003 setup:
    -----------------
    pms5003.setup(1) -- turn on and off using D1
    pms5003.disable_sensor()
    pms5003.on('datapoint',
      function (
        pm1_ug_m3,
        pm25_ug_m3,
        pm10_ug_m3,
        count_003,
        count_005,
        count_010,
        count_025,
        count_050,
        count_100)
        mqttwrap.maybepublish("debug/particles/uart", string.format("Emitting pms5003 data point count_003=%d",count_003), 0, 0)
        --mqttwrap.maybepublish("debug/particles/uart", "Emitting pms5003 data point", 0, 0)

        local tm = rtctime.epoch2cal(rtctime.get())
        local buf = ''
        buf = string.format('{"ts":"%04d-%02d-%02dT%02d:%02d:%02dZ","type":"pms5003","device":"%s", "location": "%s", "ug_per_cubic_metre": {"1.0": %d, "2.5": %d, "10": %d}, "particle_count_per_0.1l": {">0.3um": %d, ">0.5um": %d, ">1.0um": %d, ">2.5um": %d, ">5.0um": %d, ">10um": %d}}',
          tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"],
          myname,
          location,
          pm1_ug_m3,
          pm25_ug_m3,
          pm10_ug_m3,
          count_003,
          count_005,
          count_010,
          count_025,
          count_050,
          count_100
          )
        mqttwrap.maybepublish("datainput/"..location.."/"..myname, buf, 0, 0)
        pms5003.disable_sensor()
      end
    )
    -- For every interval, turn on the sensor, and rely on callback to disable
    -- again:
    tmr_meas = tmr.create()
    tmr_meas:register(600000, tmr.ALARM_AUTO, function ()
        pms5003.enable_sensor()
        mqttwrap.maybepublish("debug/particles/uart", "Triggered PMS5003...", 0, 0)
    end)
    tmr_meas:start()


    ----------------
    -- CCS811 setup:
    ----------------
    print("setting up ccs811...")
    ccs811wrap.on("datapoint", function(d)
      local tm = rtctime.epoch2cal(d.epochtime)
      local buf = ''
      if d.epochtime > time_boot + ccs811wrap.uptime_before_iaq_sensor_trusted_s then
        buf = string.format('{"ts":"%04d-%02d-%02dT%02d:%02d:%02dZ","type":"ccs811","device":"%s", "location": "%s", "eCO2": %d, "eTVOC": %d, "baseline": %d, "raw": {"I": %d,"V": %d}}',
          tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"],
          myname,
          location,
          d.eCO2,
          d.eTVOC,
          d.baseline,
          d.rawI,
          d.rawV
          )
      else
        buf = string.format('{"ts":"%04d-%02d-%02dT%02d:%02d:%02dZ","type":"ccs811","device":"'..myname..'", "location": "%s", "error": "too_early_measurement"}',
          tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"],
          location
        )
      end
      --print("publishing ccs811 data point:"..buf)
      mqttwrap.maybepublish("datainput/"..location.."/"..myname, buf, 0, 0)
    end)
    ccs811wrap.setup(css811_sda,css811_scl,css811_id)
    ccs811wrap.starttimer(60*1000)

  end

  -- expose
  M = {
    early = early,
    main = main,
  }
end
return M
