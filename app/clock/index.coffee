angular
    .module 'clock', [
        # Declare any module-specific dependencies here
        'common', 'ngAnimate'
    ]
    .controller 'ClockController',
    [ '$scope', '$interval', '$http', 'ForecastFactory',
    ($scope, $interval, $http, ForecastFactory) ->

        steroids.statusBar.hide()

        $scope.clock = "loading …"
        $scope.temp = 0
        $scope.toggle_tommorrow = false

        moment.locale 'de'

        skycons = new Skycons
            "color": "grey"
        skycons.play()

        tick = ->
            $scope.time = moment().format("HH:mm")
            $scope.date = moment().format("dddd, D. MMMM YYYY")

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
                    steroids.logger.error error
                else
                    tomorrow = getTomorrowData(response)

                    $scope.temp_current = response.currently.apparentTemperature
                    $scope.temp_tomorrow_min = tomorrow.temperatureMin
                    $scope.temp_tomorrow_max = tomorrow.temperatureMax

                    skycons.set "current", response.currently.icon
                    skycons.set "tomorrow", tomorrow.icon

        toggle_tommorrow_temp = ->
            $scope.toggle_tommorrow = !$scope.toggle_tommorrow

        $interval toggle_tommorrow_temp, 1000 * 10
        $interval tick, 1000
        $interval getForecast, 1000 * 60 * 10
        getForecast()

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
