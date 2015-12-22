angular
    .module 'clock', [
        # Declare any module-specific dependencies here
        'common', 'ngAnimate'
    ]
    .controller 'ClockController',
    [ '$scope', '$interval', '$http', 'ClockService', 'ForecastFactory', 'AirsensorFactory'
    ($scope, $interval, $http, ClockService, ForecastFactory, AirsensorFactory) ->

        document.addEventListener 'deviceready', ->
            window.brightness = cordova.require "cordova.plugin.Brightness.Brightness"
            brightness.setKeepScreenOn on

        window.addEventListener "batterystatus", (status) ->
            $scope.message = status.level
        , false

        # https://gka.github.io/palettes/#diverging|c0=#214290,#d8ecc7|c1=#fffd98,#be3f0f|steps=20|bez0=1|bez1=1|coL0=1|coL1=1
        temp_scale = chroma
            .scale ['#214290','#3e5296','#54629d','#6873a3','#7a84a9','#8b97ae','#9da9b4','#aebcba','#bfcebf','#d0e3c5','#fdf491','#f8df81','#f3cc73','#edb964','#e7a555','#e09247','#d87e39','#d06a2c','#c7561e','#be3f0f']
            .domain [-20,30]

        init = ->
            steroids.statusBar.hide()

            $interval tick, 1000
            $interval getForecast, 1000 * 60 * 10

            $scope.airquality =
                index: "?"
            setAirColor 0

            getForecast()
            initAirvalueStream()

        tick = ->
            $scope.time = ClockService.getTime()
            $scope.date = ClockService.getDate()

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

        initAirvalueStream = ->
            steroids.logger.log "initAirvalueStream"
            AirsensorFactory.streamAirsensor (data) ->
                steroids.logger.log "initAirvalueStream"
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
