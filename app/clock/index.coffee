angular
    .module 'clock', [
        # Declare any module-specific dependencies here
        'common', 'ngAnimate'
    ]
    .controller 'ClockController',
    [ '$scope', '$interval', 'ClockService', 'ForecastFactory', 'AirsensorFactory', 'DimmerService'
    ($scope, $interval, ClockService, ForecastFactory, AirsensorFactory, DimmerService) ->

        document.addEventListener 'deviceready', ->
            window.brightness = cordova.require "cordova.plugin.Brightness.Brightness"
            brightness.setKeepScreenOn on
            dim()

        # https://gka.github.io/palettes/#diverging|c0=#214290,#d8ecc7|c1=#fffd98,#be3f0f|steps=20|bez0=1|bez1=1|coL0=1|coL1=1
        temp_scale = chroma
            .scale ['#214290','#364c94','#455798','#53619c','#606ca0','#6c78a4','#7983a8','#858fac','#8f9bb0','#9ba7b3','#a6b3b7','#b1c0bb','#bdccbe','#c7d9c2','#d2e6c5','#fef793','#fbea89','#f8dd7f','#f4d076','#f1c46c','#edb762','#e8aa59','#e49d50','#df9146','#da833d','#d57734','#d06a2b','#ca5c22','#c44f19','#be3f0f']
            .domain [-20,35]

        init = ->
            steroids.statusBar.hide()

            $interval tick, 1000
            $interval dim, 1000 * 60 * 10
            $interval getForecast, 1000 * 60 * 10

            $scope.airquality =
                index: "?"
            setAirColor 0

            getForecast()
            initAirvalueStream()


        tick = ->
            $scope.time = ClockService.getTime()
            $scope.date = ClockService.getDate()

        dim = ->
            h = moment().hour()
            d = DimmerService.dim h
            brightness.setBrightness d

        $scope.getTempColor = (celcius) ->
            color = temp_scale celcius
            color: color.hex()

        setAirColor = (hsl) ->
            color = one.color "hsl(#{hsl}, 100%, 50%)"
            $scope.airColor = color: color.hex()

        getTomorrowData = (response) ->
            tomorrow = moment()
                .add 1, 'd'
                .startOf 'day'
                .utc()

            find = find || {}
            steroids.logger.log "Tommorrow is #{tomorrow.format()}"
            find.time = parseInt(tomorrow.format 'X')
            tomorrow_data = _.where response.daily.data, find
            tomorrow_data[0]


        getForecast = ->
            ForecastFactory.currentForecast (error, response) ->
                if error
                    steroids.logger.error "Error occured: #{error}"
                else
                    $scope.weather_current = response.currently
                    $scope.weather_tomorrow = getTomorrowData(response)
                    $scope.message = response.daily.summary

        initAirvalueStream = ->
            AirsensorFactory.streamAirsensor (data) ->
                $scope.$apply  () ->
                    $scope.airquality = data
                    setAirColor $scope.airquality.hsl

        init()

    ]
    .directive 'animateOnChange', ($animate, $timeout) ->
        (scope, elem, attr) ->
            scope.$watch attr.animateOnChange, (nv, ov) ->
                if nv != ov
                    $animate.addClass elem, 'change'
                    .then ->
                        $timeout ->
                            $animate.removeClass elem, 'change'
                        , 2000
