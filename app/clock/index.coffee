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

        steroids.statusBar.hide()

        tick = ->
            $scope.time = ClockService.getTime()
            $scope.date = ClockService.getDate()

        setAirColor = () ->
            color = one.color "hsl(#{$scope.airquality.hsl}, 100%, 50%)"
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
                steroids.logger.log "initAirvalueStream data:"
                steroids.logger.log data
                $scope.$apply  () ->
                    $scope.airquality = data
                    setAirColor()


        $interval tick, 1000
        $interval getForecast, 1000 * 60 * 10
        getForecast()
        initAirvalueStream()

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
