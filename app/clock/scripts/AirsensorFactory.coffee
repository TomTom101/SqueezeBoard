angular
    .module 'clock'
    .factory 'AirsensorFactory',
    () ->

        airstream = null
        reconnecting = false

        Number::map = (in_min, in_max, out_min, out_max) ->
          parseInt((this - in_min) * (out_max - out_min) / (in_max - in_min) + out_min)

        doEvery = (sec, func) -> setInterval func, sec * 1000
        doIn = (sec, func) -> setTimeout func, sec * 1000

        connectSSE = (callback)->
            airstream = new EventSource 'http://192.168.0.18:8080/rest/events?topics=smarthome/items/exec_command_927931ae_output/state'
            airstream.addEventListener "message", (message) ->
              event = JSON.parse message.data
              if event.type is 'ItemStateEvent'
                data = JSON.parse event.payload
                callback qualityIndex data.value

            airstream.onerror = ->
              steroids.logger.log "EventSource error"
              callback qualityIndex 'error'


        streamAirsensor = (callback) ->
            doEvery 10, ->
              if airstream.readyState is 2
                steroids.logger.log "Reconnect now"
                connectSSE callback

            if (typeof EventSource is "undefined")
                steroids.logger.log "EventSource not supported! Bad."
            else
                connectSSE callback



        qualityIndex = (data) ->
            voc = parseInt(data)
            if isNaN(voc)
              hslHue = 0
              voc = '-'
            else
              hslHue = voc.map(100, 0, 120, 0) # 120 is the HSL angle for green, 0 is red

            hsl: hslHue
            index: voc

        streamAirsensor: streamAirsensor
