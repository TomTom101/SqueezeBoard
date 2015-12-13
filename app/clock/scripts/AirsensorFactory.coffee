angular
    .module 'clock'
    .factory 'AirsensorFactory',
    () ->

        Number::map = (in_min, in_max, out_min, out_max) ->
            parseInt((this - in_min) * (out_max - out_min) / (in_max - in_min) + out_min)


        streamAirsensor = (callback) ->
            if (typeof EventSource is "undefined")
                steroids.logger.log "EventSource not supported!"
            else
                airstream = new EventSource 'http://192.168.0.18:3001/stream'
                airstream.onmessage = (message) ->
                    callback qualityIndex JSON.parse message.data


        qualityIndex = (data) ->
            voc = parseInt(data.e[0].v)
            hslHue = voc.map(450, 2000, 120, 0) # 120 is the HSL angle for green, 0 is red
            index = voc.map(450, 2000, 100, 0) # quality index from 0 to 100

            hsl: hslHue
            index: index

        streamAirsensor: streamAirsensor
