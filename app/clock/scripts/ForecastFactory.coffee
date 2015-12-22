angular
    .module 'clock'
    .factory 'ForecastFactory',
    [ '$interval', '$http',
    ($interval, $http) ->
        apiKey = '9fe2490f9dbac2962a251e23ca99e81a'
        lat = '52.5158'
        lon = '13.4725'
        interval = 1000 * 60 * 15
        cachedForecast = null

        pollForecastIO = (callback) ->
            steroids.logger.log "polling ForecastFactory"
            url = ['https://api.forecast.io/forecast/', apiKey, '/', lat, ',', lon].join ''
            url+= ['?callback=JSON_CALLBACK', 'exclude=minutely,hourly', 'lang=de', 'units=ca'].join '&'

            $http.jsonp url
                .success (data) ->
                    callback(null, data)
                .error (error) ->
                    steroids.logger.error error
                    callback(error)

        currentForecast = (callback) ->
            if not cachedForecast
                pollForecastIO (err, data) ->
                    cachedForecast = data
                    callback(null, cachedForecast)
            else
                callback(null, cachedForecast)

#     // poll on an interval to update forecast
        $interval ->
            pollForecastIO (err, data) ->
                cachedForecast = data
        , interval

        currentForecast: currentForecast
    ]
