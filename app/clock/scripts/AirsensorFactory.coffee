angular
    .module 'clock'
    .factory 'AirsensorFactory',
    [ '$interval', '$http',
    ($interval, $http) ->
        interval = 1000 * 60
        cachedForecast = null

        Number::map = (in_min, in_max, out_min, out_max) ->
            parseInt((this - in_min) * (out_max - out_min) / (in_max - in_min) + out_min)

        pollAirsensor = (callback) ->
            steroids.logger.log "polling AirsensorFactory"
            url = 'http://192.168.0.18:3001/'

            $http.get url
                .then (data) ->
                    callback(null, data)
                , (error) ->
                    steroids.logger.error error
                    callback(error)
        qualityIndex = (callback) ->
            currentAirvalues (err, data) ->
                voc = parseInt(data.data.e[0].v)
                hslHue = voc.map(450, 2000, 120, 0) # 120 is the HSL angle for green, 0 is red
                steroids.logger.log "From #{voc} to #{hslHue}"
                callback null, hslHue


        currentAirvalues = (callback) ->
            if not cachedForecast
                pollAirsensor (err, data) ->
                    cachedForecast = data
                    callback(null, cachedForecast)
            else
                callback(null, cachedForecast)

#     // poll on an interval to update forecast
        $interval ->
            pollAirsensor (err, data) ->
                cachedForecast = data
        , interval

        currentAirvalues: currentAirvalues
        qualityIndex: qualityIndex
    ]
