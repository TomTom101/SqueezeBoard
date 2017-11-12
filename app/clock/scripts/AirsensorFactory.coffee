angular
    .module 'clock'
    .factory 'AirsensorFactory',
    () ->

        Number::map = (in_min, in_max, out_min, out_max) ->
            parseInt((this - in_min) * (out_max - out_min) / (in_max - in_min) + out_min)


        streamAirsensor = (callback) ->
            if (typeof EventSource is "undefined")
                steroids.logger.log "EventSource not supported! Bad."
            else
                airstream = new EventSource 'http://192.168.0.18:8080/rest/events?topics=smarthome/items/exec_command_927931ae_output/state'
                airstream.addEventListener "message", (message) ->
                  event = JSON.parse message.data
                  if event.type is 'ItemStateChangedEvent'
                    data = JSON.parse event.payload
                    callback qualityIndex data.value

                airstream.onerror= (error) ->
                  steroids.logger.log "Error with EventSource"


        qualityIndex = (data) ->
            voc = parseInt(data)
            hslHue = voc.map(100, 0, 120, 0) # 120 is the HSL angle for green, 0 is red

            hsl: hslHue
            index: voc

        streamAirsensor: streamAirsensor
